test <- college_FE %>% 
  select(intzone_2011, sg_quintile, category) %>% 
  group_by(intzone_2011, category) %>% 
  summarise(total = n()) %>% 
  spread(category, total) %>% 
  mutate(Progress = replace_na(Progress,0),
         Regress = replace_na(Regress,0),
         Repeat = replace_na(Repeat,0),
         sum = Progress+Regress+Repeat,
         progress_prop = round(Progress/sum*100, 1))
#####################################################################################################

library(leaflet)
options("rgdal_show_exportToProj4_warnings"="none")
library(rgdal)
library(tmaptools)

int_zones <- readOGR("M:/Performance Measurement & Analysis/Josh/Misc/schoolleaver/SG_IntermediateZoneBdry_2011/SG_IntermediateZone_Bdry_2011.shp",
                  layer = "SG_IntermediateZone_Bdry_2011",
                  GDAL1_integer64_policy = T)

#converting to WGS84 and simplifying
wgs_int_zones <- spTransform(int_zones, CRS("+proj=longlat +datum=WGS84"))
simplified_wgs_int_zones <- rmapshaper::ms_simplify(wgs_int_zones)

#####################################################################################################
#merging dataset to shapefile

joined_shapefile <- merge(simplified_wgs_int_zones, test, by.x = "InterZone", by.y = "intzone_2011") %>% 
  filter(joined_shapefile@data$progress_prop, !is.na(progress_prop))

#####################################################################################################

pal <- colorNumeric(
  palette = 'Purples',
  domain = joined_shapefile$progress_prop
)

labels <- sprintf(
  "<font size = 5>%s</font><br/>
  TOTAL LEAVERS GOING TO FE: %s <br/>
  Number of school leavers progressing: %s<br/>
  Number of school leavers repeating: %s<br/>
  Number of school leavers regressing: %s <br/>
  <strong> Proportion of school leavers progressing: %s</strong></font>",
  joined_shapefile$Name,
  joined_shapefile$sum,
  joined_shapefile$Progress,
  joined_shapefile$Repeat,
  joined_shapefile$Regress,
  paste0(joined_shapefile$progress_prop, '%')) %>%
  lapply(htmltools::HTML)


output <- test %>% 
  leaflet() %>% 
  addProviderTiles(providers$Esri.WorldShadedRelief) %>% 
  addPolygons(
    color = "#444444",
    data = joined_shapefile,
    weight = 1,
    smoothFactor = 0.5,
    opacity = 1.0,
    fillOpacity = .7,
    fillColor = ~pal(joined_shapefile$progress_prop),
    label = labels,
    highlightOptions = highlightOptions(
      color = "white",
      weight = 2,
      bringToFront = T)) %>% 
  addLegend("bottomright", 
            pal = pal,
            values = ~joined_shapefile$progress_prop,
            title = "Proportion of school leavers in FE,<br/> progressing to next SCQF level, 2018-19",
            labFormat = labelFormat(suffix = "%"),
            opacity = 1)



library(mapview)
mapshot(output, url = "ex1.html")
