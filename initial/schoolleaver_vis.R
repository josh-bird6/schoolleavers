library(tidyverse)

basedata1 <- read_csv("schoolleaver_basedata_final.csv")

basedata1 %>% 
  filter(shefcint !="Open University in Scotland",
         school_type %in% c("Independent", "Local Authority")) %>% 
  group_by(shefcint, school_type) %>% 
  summarise(total = n()) %>% 
  spread(school_type, total) %>% 
  mutate(total = Independent + `Local Authority`,
         independent_percent = round(Independent/total*100, 1),
         LA_total = round(`Local Authority`/total*100, 1),
         difference = independent_percent - LA_total,
         university = ifelse(shefcint == "Scottish Agricultural College", "SRUC", shefcint)) %>% 
  gather("classification", "total", 5:6) %>% 
  ggplot(aes(x=reorder(university, difference), y=total, fill = classification)) +
  geom_col(position = "stack") +
  coord_flip() +
  theme_bw() +
  theme(legend.title = element_blank())+
  # theme(legend.position = "bottom") +
  labs(title = "Figure 2: School leaver entrants to Scottish HEIs by school type, 2018-19",
       x="University",
       y="%",
       caption = "NOTE: Only includes Scottish-domiciled students commencing a first-degree course in AY2018-19") +
  scale_fill_manual(values = c("#fecc5c", "#f03b20"),
                    labels = c( "Independent School", "Local Authority School")) +
  geom_text(aes(label = ifelse(total <10, "", paste0(total,"%"))), position = position_stack(vjust = .5))

##################################################################
basedata1 %>% 
  filter(shefcint !="Open University in Scotland",
         school_type %in% c("Independent", "Local Authority"),
         !is.na(simd16_quintile)) %>% 
  group_by(school_type, simd16_quintile) %>% 
  summarise(total = n()) %>% 
  spread(simd16_quintile, total) %>% 
  mutate(`1`=replace_na(`1`,0),
         `2`=replace_na(`2`,0),
         `3`=replace_na(`3`,0),
         `4`=replace_na(`4`,0),
         overall = sum(`1`,`2`,`3`,`4`,`5`),
         simd1_percent = round(`1`/overall*100,1),
         simd2_percent = round(`2`/overall*100,1),
         simd3_percent = round(`3`/overall*100,1),
         simd4_percent = round(`4`/overall*100,1),
         simd5_percent = round(`5`/overall*100,1),
         difference = simd5_percent - simd1_percent) %>% 
  gather("simd_percent", "percent", 8:12) %>% 
  ggplot(aes(x=school_type, y=percent, fill=simd_percent)) +
  geom_col(position = "stack") +
  coord_flip() +
  scale_fill_manual(values = c("#ffffb2",
                               "#fecc5c",
                               "#fd8d3c",
                               "#f03b20",
                               "#bd0026"),
                    labels = c("SIMD20",
                               "SIMD40",
                               "SIMD60",
                               "SIMD80",
                               "SIMD100")) +
  theme_bw() +
  theme(legend.title = element_blank())+
  labs(title = "Figure 3: SIMD profiles by school type, 2018-19",
      x="School Type",
      y="%",
      caption = "NOTE: Omits N/As") +
  geom_text(aes(label = ifelse(percent <5, "", paste0(percent,"%"))), position = position_stack(vjust = .5))

##################################################################

read_csv("SFC_InitialDestinations_DataShare_20200709.csv") %>% 
  group_by(academic_year, Initial_Reported_Destination) %>% 
  summarise(total = n()) %>% 
  filter(Initial_Reported_Destination != "Unknown") %>% 
  ggplot(aes(x=academic_year, y=total, group = Initial_Reported_Destination, colour = Initial_Reported_Destination)) +
  geom_line()+
  geom_point()+
  theme_bw() +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Figure 1: Initial reported destinations of school leavers, 2016-17 to 2018-19",
       x="Academic Year",
       y="") +
  theme(legend.title = element_blank()) +
  scale_color_brewer(palette = "Set1") +
  geom_text(aes(label = ifelse(total >5000 , scales::comma(total), "")), vjust = -.5)

read_csv("SFC_InitialDestinations_DataShare_20200709.csv") %>% 
  filter(Initial_Reported_Destination != "Unknown") %>% 
  group_by(academic_year, Initial_Reported_Destination) %>% 
  summarise(total = n()) %>% 
  ggplot(aes(x=academic_year, y=total, fill = Initial_Reported_Destination)) +
  geom_col(position = "stack") +
  theme_bw() +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Figure 1: Initial reported destinations of school leavers, 2016-17 to 2018-19",
       x="Academic Year",
       y="") +
  theme(legend.title = element_blank()) +
  scale_fill_brewer(palette = "Set1") +
  geom_text(aes(label = ifelse(total >5000 , scales::comma(total), "")), vjust = -.5)

test <- read_csv("SFC_InitialDestinations_DataShare_20200709.csv") %>% 
  filter(Initial_Reported_Destination != "Unknown") %>% 
  group_by(academic_year, Initial_Reported_Destination) %>% 
  summarise(total = n()) %>% 
  spread(academic_year, total)
  
  
            
