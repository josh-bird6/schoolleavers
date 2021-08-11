library(tidyverse)

college_basedata <- read_csv("college_201819.csv") %>% 
  mutate(category = ifelse(adv==1, "Higher Education", "Further Education"))

uni_basedata <- read_csv("uni_201819.csv") 
#######################
###################################
#####################
library(networkD3)

links <- data.frame(
  source = c("School leavers (49,748)", "School leavers (49,748)", "Tertiary Education (35,413)â ", "Tertiary Education (35,413)â ", "Tertiary Education (35,413)â "),
  target = c("Tertiary Education (35,413)â ", "Other destination (employment, training, etc)", "University (13,779)â ", "College - HE (5,631)", "College - FE (16,003)"),
  value = c(35413, 14335, 13779, 5631, 16003))

nodes <- data.frame(
  name = c(as.character(links$source),
           as.character(links$target)) %>% 
    unique())

links$IDsource <- match(links$source, nodes$name)-1
links$IDtarget <- match(links$target, nodes$name)-1

my_color <- 'd3.scaleOrdinal() .domain(["School leavers (49,798)", "Tertiary Education (36,986)", "Other destination (employment, training, etc)","University (15,352)", "College - HE (5,631)", "College - FE (16,003)"]) 
.range(["#08306b", "#2171b5", "#f7fbff", "#6baed6", "#c6dbed", "#c6dbed"])'

sankeyNetwork(
  Links = links,
  Nodes = nodes,
  Source = 'IDsource',
  Target = 'IDtarget',
  Value = 'value',
  NodeID = 'name',
  sinksRight = F,
  fontSize = 16,
  fontFamily = 'sans-serif',
  colourScale = my_color,
  nodePadding = 50,
  width =900,
  height = 480
) 

# fig1_uni <- uni_basedata %>% 
#   group_by(schoolleaver) %>% 
#   summarise(total = sum(head)) %>% 
#   mutate(category = ifelse(schoolleaver==1, "University", "")) %>% 
#   select(-schoolleaver)
# 
# fig1_college <- college_basedata %>% 
#   group_by(adv) %>% 
#   summarise(total = n()) %>% 
#   mutate(category = ifelse(adv==1, 
#                            "College - HE", 
#                            "College - FE")) %>% 
#   select(-adv)
# 
# rbind(fig1_uni, fig1_college) %>% 
#   ggplot(aes(x=category, y=total, fill = category))+
#   geom_col()+
#   theme_bw()+
#   coord_flip() +
#   theme(legend.position = "none") +
#   scale_y_continuous(label = scales::comma)+
#   labs(title = "Figure 1: School leavers by study level, 2018-19",
#        x="",
#        y="") +
#   geom_text(aes(label = scales::comma(total), hjust = 1))
#######################
###################################
#####################

college_basedata %>% 
  group_by(category, college_region) %>% 
  summarise(total = n()) %>% 
  ggplot(aes(x=college_region, y=total, fill=category)) +
  geom_col(position = 'stack') +
  coord_flip() +
  theme_bw()

uni_basedata %>% 
  group_by(shefcint, school_type) %>% 
  summarise(total = n()) %>% 
  ggplot(aes(x=shefcint, y=total, fill=school_type))+
  geom_col(position = 'stack') +
  coord_flip()+
  theme_bw()
#######################
###################################
#####################
joina <- uni_basedata %>% 
  filter(shefcint !="Open University in Scotland",
         !is.na(simd16_quintile)) %>% 
  group_by(school_type, simd16_quintile) %>% 
  summarise(total = n()) 

joinb <-  uni_basedata %>% 
  filter(shefcint !="Open University in Scotland",
         !is.na(simd16_quintile)) %>% 
  group_by(simd16_quintile) %>% 
  summarise(total = n()) %>% 
  mutate(school_type = "Scotland Total") %>% 
  select(school_type, everything())

bind_rows(joina, joinb) %>% 
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
  ggplot(aes(x=school_type, y=percent, fill=factor(simd_percent, levels = c("simd5_percent",
                                                                            "simd4_percent",
                                                                            "simd3_percent",
                                                                            "simd2_percent",
                                                                            "simd1_percent")))) +
  geom_col(position = "stack") +
  coord_flip() +
  scale_fill_manual(values = c("#c6dbef",
                               "#9ecae1",
                               "#6baed6",
                               "#3182bd",
                               "#08519c"),
                    labels = c("SIMD80100",
                               "SIMD6080",
                               "SIMD4060",
                               "SIMD4060",
                               "SIMD020")) +
  theme_bw() +
  theme(legend.title = element_blank())+
  labs(title = "Figure 4: SIMD profiles by school type, 2018-19",
       x="School Type",
       y="%",
       caption = "NOTE: Omits N/As") +
  geom_text(aes(label = ifelse(percent <5, "", paste0(percent,"%"))), position = position_stack(vjust = .5))

#######################
###################################
#####################

final <- uni_basedata %>% 
  filter(shefcint !="Open University in Scotland") %>% 
  group_by(shefcint, school_type) %>% 
  summarise(total = n()) 

final2 <- 
  uni_basedata %>% 
  filter(shefcint !="Open University in Scotland") %>% 
  group_by(school_type) %>% 
  summarise(total = n()) %>% 
  mutate(shefcint = "SCOTLAND AVERAGE") %>% 
  select(shefcint, everything())

bind_rows(final, final2) %>% 
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
       y="%") +
  scale_fill_manual(values = c("#3182bd", "#9ecae1"),
                    labels = c( "Independent School", "Local Authority School")) +
  geom_text(aes(label = ifelse(total <10, "", paste0(total,"%"))), position = position_stack(vjust = .5))+
  scale_y_continuous(breaks = seq(0,100, 10))


uni_basedata %>%
  filter(shefcint !="Open University in Scotland",
         !is.na(simd16_quintile)) %>%
  mutate(shefcint = ifelse(shefcint == "Scottish Agricultural College", "SRUC", shefcint)) %>% 
  group_by(shefcint, school_type, simd16_quintile) %>%
  summarise(total = n()) %>%
  spread(simd16_quintile, total) %>%
  mutate(`1`=replace_na(`1`,0),
          `2`=replace_na(`2`,0),
          `3`=replace_na(`3`,0),
          `4`=replace_na(`4`,0),
         overall = sum(`1`,`2`,`3`,`4`,`5`),
         SIMD80100 = round(`5`/overall*100,1),
         SIMD6080 = round(`4`/overall*100,1),
         SIMD4060 = round(`3`/overall*100,1),
         SIMD2040 = round(`2`/overall*100,1),
         SIMD020 = round(`1`/overall*100,1),
         difference = SIMD80100-SIMD020) %>%
  gather("simd_percent", "percent",9:13) %>%
  filter(school_type=="Local Authority") %>% 
  ggplot(aes(x=reorder(shefcint,difference), y=percent, fill = factor(simd_percent, levels = c("SIMD80100",
                                                                                               "SIMD6080",
                                                                                               "SIMD4060",
                                                                                               "SIMD2040",
                                                                                               "SIMD020")))) +
  geom_col(position = "stack") +
  scale_fill_brewer(palette = "Blues") +
  coord_flip() +
  theme_bw() +
  theme(legend.title = element_blank())+
  labs(title = "Figure 2: Local Authority school leaver entrants to Scottish HEIs by SIMD, 2018-19",
       subtitle = "Ordered by % difference between SIMD80100 and SIMD020",
       x="University",
       y="%",
       caption = "NOTE: Omits leavers without postcode") +
  # scale_fill_manual(values = c("#fecc5c", "#f03b20"),
  #                   labels = c( "Independent School", "Local Authority School")) +
  geom_text(aes(label = ifelse(percent <10, "", paste0(percent,"%"))), position = position_stack(vjust = .5))
