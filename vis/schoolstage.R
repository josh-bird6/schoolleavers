
schoolstage_college <- 
  college_basedata %>% 
  mutate(category = ifelse(category == "Higher Education", "College - HE", "College - FE"),
         institution = college_name2,
         boob = ifelse(category == "College - HE" & institution == "Newbattle Abbey College", 0, 1)) %>% 
  select(-college_name2) %>% 
  group_by(category, institution, schoolyear, boob) %>% 
  summarise(total = n()) %>% 
  filter(schoolyear %in% c("S4", "S5", "S6")) %>% 
  spread(schoolyear, total)%>% 
  mutate(S4=replace_na(S4,0),
         S5=replace_na(S5,0),
         S6=replace_na(S6,0),
         summed = sum(S4, S5, S6),
         S4_percent = round(S4/summed*100,1),
         S5_percent = round(S5/summed*100,1),
         S6_percent = round(S6/summed*100,1)) %>% 
  gather("Year", "proportion", 8:10) %>%
  filter(boob ==1) %>% 
  ggplot(aes(x=institution, y=proportion, fill = factor(Year, levels = c("S6_percent","S5_percent","S4_percent")))) +
  geom_col(position = "stack") +
  theme_bw() +
  coord_flip()+
  facet_wrap(~category, nrow = 1) +
  scale_fill_manual(values = c("#c6dbef",
                               "#6baed6",
                               "#3182bd"),
                    labels = c("S6",
                               "S5",
                               "S4")) +
  labs(title = "Figure 1: School leaving stage by study level and institution, 2018-19",
       x="Institution name",
       y="%") +
  theme(legend.title = element_blank()) +
  geom_text(aes(label = ifelse(proportion <5, "", paste0(proportion,"%")) ), position = position_stack(vjust = .5), size = 4.5) +
  scale_y_continuous(breaks = seq(0,100, 10))



schoolstage_university <- uni_basedata %>% 
  filter(school_type == "Local Authority",
         shefcint != "Open University in Scotland") %>% 
  mutate(institution =  ifelse(shefcint == "Scottish Agricultural College", "SRUC", shefcint)) %>% 
  select(-shefcint) %>% 
  group_by(institution, schoolyear) %>% 
  summarise(total = n()) %>% 
  mutate(category = "University*") %>% 
  filter(schoolyear !="S9") %>% 
  select(category, institution, schoolyear, total) %>% 
  spread(schoolyear, total)%>% 
  mutate(S4=replace_na(S4,0),
         S5=replace_na(S5,0),
         S6=replace_na(S6,0),
         summed = sum(S4, S5, S6),
         S4_percent = round(S4/summed*100,1),
         S5_percent = round(S5/summed*100,1),
         S6_percent = round(S6/summed*100,1),
         difference = S6_percent - S4_percent) %>% 
  gather("Year", "proportion", 7:9) %>%
  ggplot(aes(x=reorder(institution,difference), y=proportion, fill = factor(Year, levels = c("S6_percent",
                                                                                             "S5_percent",
                                                                                             "S4_percent")))) +
  geom_col(position = "stack") +
  theme_bw() +
  coord_flip()+
  facet_wrap(~category, ncol = 1) +
  scale_fill_manual(values = c("#c6dbef",
                               "#6baed6",
                               "#3182bd"),
                    labels = c("S6",
                               "S5",
                               "S4")) +
  theme(legend.title = element_blank()) +
  labs(x="Institution name",
       y="%",
       caption = "*Only includes leavers from Local Authority schools because they came from the \n SDS dataset and therefore had a school leaving year") +
  geom_text(aes(label = ifelse(proportion <5, "", paste0(proportion,"%"))), position = position_stack(vjust = .5)) +
  scale_y_continuous(breaks = seq(0,100, 10))


ggarrange(schoolstage_college, schoolstage_university, ncol=1)
#####################
college <- college_basedata %>% 
  mutate(category = ifelse(category == "Higher Education", "College - HE", "College - FE")) %>% 
  group_by(category, schoolyear) %>% 
  summarise(total = n()) %>% 
  filter(schoolyear %in% c("S4", "S5", "S6")) %>% 
  spread(schoolyear, total) %>% 
  mutate(summed = sum(S4, S5, S6),
         S4_percent = round(S4/summed*100,1),
         S5_percent = round(S5/summed*100,1),
         S6_percent = round(S6/summed*100,1)) %>% 
  gather("Year", "proportion", 6:8) %>% 
  mutate(Year = ifelse(Year == "S4_percent", "S4",
                       ifelse(Year == "S5_percent", "S5", "S6")))

uni <- uni_basedata %>% 
  filter(school_type == "Local Authority",
         shefcint != "Open University in Scotland") %>% 
  group_by(schoolyear) %>% 
  summarise(total = n()) %>% 
  mutate(category = "University*") %>% 
  filter(schoolyear !="S9") %>% 
  select(category, everything()) %>% 
  spread(schoolyear, total)%>% 
  mutate(summed = sum(S4, S5, S6),
         S4_percent = round(S4/summed*100,1),
         S5_percent = round(S5/summed*100,1),
         S6_percent = round(S6/summed*100,1)) %>% 
  gather("Year", "proportion", 6:8) %>% 
  mutate(Year = ifelse(Year == "S4_percent", "S4",
                       ifelse(Year == "S5_percent", "S5", "S6")))

bind_rows(college, uni) %>% 
  ggplot(aes(x=category, y=proportion, fill = factor(Year, levels = c("S6",
                                                                      "S5",
                                                                      "S4")))) +
  geom_col(position = "stack") +
  coord_flip()+
  theme_bw() +
  geom_text(aes(label = ifelse(proportion <3, "", paste0(proportion,"%"))), position = position_stack(vjust = .5)) +
  scale_y_continuous(breaks = seq(0,100, 10)) +
  theme(legend.title = element_blank()) +
  scale_fill_manual(values = c("#c6dbef",
                               "#6baed6",
                               "#3182bd")) +
  labs(x="Study level",
       y="%",
       caption = "*Only includes leavers from Local Authority schools and not attending The Open University",
       title = "School leaving year proportions across all study levels, 2018-19") 
  
  
#####################

a <- uni_basedata %>%
  filter(shefcint !="Open University in Scotland",
         !is.na(simd16_quintile)) %>%
  mutate(shefcint = ifelse(shefcint == "Scottish Agricultural College", "SRUC", shefcint)) %>% 
  group_by(shefcint, school_type, simd16_quintile) %>%
  summarise(total = n()) 

b<- uni_basedata %>% 
  filter(shefcint !="Open University in Scotland",
         !is.na(simd16_quintile)) %>%
  mutate(shefcint = ifelse(shefcint == "Scottish Agricultural College", "SRUC", shefcint)) %>% 
  group_by(school_type, simd16_quintile) %>% 
  summarise(total = n()) %>% 
  mutate(shefcint = "SCOTLAND AVERAGE") %>% 
  select(shefcint, everything())

rbind(a, b) %>%
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
         difference = SIMD80100 - SIMD020) %>%
  filter(school_type=="Local Authority") %>% 
  arrange(difference) %>%
  # mutate(rankandfile = SIMD020) %>% 
  gather("simd_percent", "percent",9:13) %>%
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
  labs(title = "Figure 3: Local Authority school leaver entrants to Scottish HEIs by SIMD, \n2018-19",
       subtitle = "Ordered by SIMD020%",
       x="University",
       y="%",
       caption = "NOTE: Omits leavers without postcode") +
  # scale_fill_manual(values = c("#fecc5c", "#f03b20"),
  #                   labels = c( "Independent School", "Local Authority School")) +
  geom_text(aes(label = ifelse(percent <10, "", paste0(percent,"%"))), position = position_stack(vjust = .5))+
  scale_y_continuous(breaks = seq(0,100, 10))

###################################
###################################
###################################
###################################
###################################
###################################
###################################
#SOME MORE ON LEARNER JOURNEY

college_FE %>% 
  filter(!is.na(sg_quintile)) %>% 
  mutate(category=ifelse(category == "Progress", "Stepping up(n=4,155)",
                         ifelse(category== "Repeat", "Static(n=7,052)",
                                "Stepping Down(n=4,767)"))) %>% 
  ggplot(aes(x=sg_quintile, 
             y=factor(category,levels = c('Stepping Down(n=4,767)', 'Static(n=7,052)', 'Stepping up(n=4,155)')), 
             height = ..density.., 
             fill = category)) +
  geom_joy(scale=0.85)+
  theme_bw() +
  labs(x="SIMD Quintile",
      y= "SCQF progression",
      title = "Figure 2: School leaver SCQF progression by income quintile, 2018-19",
      caption = "NOTE: Omits N/As") +
  scale_fill_manual(values = c("#6baed6",
                               "#c6dbef",
                               "#3182bd")) +
  theme(legend.position = "none") +
  annotate('text', x= .5, y=1.5, label ="SIMD020:\n 33.4%")+
  annotate('segment', x=.6, y=1.5, xend=1, yend=1.5) +
  annotate('text', x= 5.5, y=1.5, label ="SIMD80100:\n 10.1%")+
  annotate('segment', x=5.4, y=1.5, xend=5, yend=1.25) 
 
  #wranging for chart above

simda<- college_FE %>% 
  filter(!is.na(sg_quintile)) %>% 
  group_by(sg_quintile) %>% 
  summarise(total =n()) %>% 
  spread(sg_quintile, total) %>% 
  mutate(category = "Scotland Overall") %>% 
  select(category, everything())

simdb <- college_FE %>% 
  filter(!is.na(sg_quintile)) %>% 
  group_by(category, sg_quintile) %>% 
  summarise(total =n()) %>% 
  spread(sg_quintile, total)
  
  
bind_rows(simda, simdb) %>% 
  mutate(sum = (`1` + `2` + `3` +`4`+`5`),
         SIMD020 = round(`1` / sum * 100, 1), 
         SIMD2040 = round(`2` / sum * 100, 1),
         SIMD4060 = round(`3` / sum * 100, 1),
         SIMD6080 = round(`4` / sum * 100, 1),
         SIMD80100 = round(`5` / sum * 100, 1)) %>% 
  ###############################################
  gather("SIMD", "prop", 8:12) %>%
  mutate(category2=ifelse(category == "Progress", "Stepping up(n=4,155)",
                         ifelse(category== "Repeat", "Static(n=7,052)",
                                ifelse(category == "Regress", "Stepping Down(n=4,767)",
                                       "Scotland Overall (n=15,974)")))) %>% 
  ggplot(aes(x=factor(category2,levels = c('Stepping Down(n=4,767)', 'Static(n=7,052)', 'Stepping up(n=4,155)', "Scotland Overall (n=15,974)")), 
             y=prop, 
             fill = factor(SIMD, levels =c("SIMD80100", "SIMD6080", "SIMD4060", "SIMD2040", "SIMD020"))))+
  geom_col(position = "stack") +
  coord_flip()+
  theme_bw() +
  theme(legend.title = element_blank()) +
  geom_text(aes(label = paste0(prop, '%')), position = position_stack(vjust = .5), size = 4.5) +
  labs(x="Progression status", y="%", title = "Figure 2: Proportion of FE school leavers by SIMD and progression status", caption = "NOTE: Omits NAs") +
  scale_y_continuous(breaks = seq(0,100, 10), limits = c(0,100.1), expand =c(0,0)) +
  scale_fill_brewer(palette = "Blues") +
  annotate('segment', y=0, yend = 100, x=3.5, xend=3.5, size = 1)
