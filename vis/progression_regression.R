college_FE <- read_csv("college_201819.csv") %>% 
  filter(adv == 2,
         schoolyear != "S9") %>% 
  mutate(category = case_when(scqf_lev == "National 3" & schoolyear == "S3"  |
                                scqf_lev == "National 4 SVQ 1" & schoolyear == "S4" |
                                scqf_lev == "National 5 SVQ 2" & schoolyear == "S5" |
                                scqf_lev == "Higher SVQ 3" & schoolyear == "S6" ~ "Repeat",
                              scqf_lev == "National 4 SVQ 1" & schoolyear == "S3" |
                                scqf_lev == "National 5 SVQ 2" & schoolyear %in% c("S3", "S4") |
                                scqf_lev == "Higher SVQ 3" & schoolyear %in% c("S3", "S4", "S5") |
                                scqf_lev == "Advanced Higher HNC. CertHE. SVQ 3" & schoolyear %in% c("S4", "S5", "S6") ~ "Progress"),
         category = ifelse(category %in% c("Repeat", "Progress"), category, "Regress"),
         mode2 = ifelse(mode == "Full Time", "Full Time", "Part Time"),
         college_name2 = ifelse(college_region == "Highlands and Islands", "Highlands and Islands", college_name))


college_FE %>% 
  mutate(mode2 = ifelse(mode == "Full Time", "Full Time (n=12,255)", "Part Time (n=3,744)")) %>% 
  group_by(category, mode2) %>% 
  summarise(total = n()) %>% 
  spread(category, total) %>% 
  mutate(overall = Progress+Regress+Repeat,
         Progressing = round(Progress/overall*100,1),
         Regressing = round(Regress/overall*100,1),
         Repeating = round(Repeat/overall*100,1)) %>% 
  gather(category, proportion, 6:8) %>% 
  ggplot(aes(x=mode2, y = proportion, fill = factor(category, levels = c("Progressing",
                                                                         "Repeating", 
                                                                         "Regressing")))) +
  geom_col(position = "stack")+
  coord_flip() +
  theme_bw() +
  theme(legend.title = element_blank()) +
  scale_y_continuous(breaks = seq(0,100, 10)) +
  geom_text(aes(label = paste0(proportion, '%')), position = position_stack(vjust = .5)) +
  labs(x="Mode of Study", y="%", title = "Proportion of FE school leavers by mode and progression status")

college_FE %>%
  filter(schoolyear != "S3") %>% 
  mutate(schoolyear2 = ifelse(schoolyear == "S4", "S4(n=3,219)",
                              ifelse(schoolyear == "S5", "S5(n=6,317)",
                                     "S6(n=6,452)"))) %>% 
  group_by(category, schoolyear, mode2) %>% 
  summarise(total = n()) %>% 
  spread(category, total) %>% 
  mutate(overall = Progress+Regress+Repeat,
         Progressing = round(Progress/overall*100,1),
         Regressing = round(Regress/overall*100,1),
         Repeating = round(Repeat/overall*100,1)) %>% 
  gather(category, proportion, 7:9) %>% 
  ggplot(aes(x=mode2, y = proportion, fill = factor(category, levels = c("Progressing",
                                                                         "Repeating", 
                                                                         "Regressing")))) +
  geom_col(position = "stack")+
  coord_flip() +
  theme_bw() +
  theme(legend.title = element_blank()) +
  facet_wrap(~schoolyear, ncol=1)+
  scale_y_continuous(breaks = seq(0,100, 10)) +
  geom_text(aes(label = paste0(proportion, '%')), position = position_stack(vjust = .5)) +
  labs(x="Mode of Study", 
       y="%", 
       title = "Figure 1: Proportion of FE school leavers by mode and progression status and leaving year",
       caption = 'NOTE: Omits S3 school leavers')

#######################
###################################
#####################
college_FE %>% 
  filter(!college_region %in% c("Newbattle Abbey College", "Sabhal Mor Ostaig")) %>%
  group_by(college_name2, category) %>% 
  summarise(total = n()) %>% 
  spread(category, total) %>% 
  mutate(overall = Progress+Regress+Repeat,
         Progressing = round(Progress/overall*100,1),
         Regressing = round(Regress/overall*100,1),
         Repeating = round(Repeat/overall*100,1),
         rank = Regressing) %>% 
  arrange(Regressing) %>% 
  gather(category, proportion, 6:8) %>% 
  ggplot(aes(x=reorder(college_name2, rank), y=proportion, fill = factor(category, levels = c("Progressing",
                                                                                                     "Repeating", 
                                                                                                     "Regressing")))) +
  geom_col(position = "stack") +
  coord_flip()+
  theme_bw() +
  theme(legend.title = element_blank()) +
  scale_y_continuous(breaks = seq(0,100, 10)) +
  geom_text(aes(label = paste0(proportion, '%')), position = position_stack(vjust = .5)) +
  labs(x="College name", 
       y="%", 
       title = "Figure 2: Proportion of FE school leavers by college and progression status 2018-19")

college_FE %>% 
  filter(!college_region %in% c("Newbattle Abbey College", "Sabhal Mor Ostaig")) %>%
  group_by(subject_1, category) %>% 
  summarise(total = n()) %>% 
  spread(category, total) %>% 
  mutate(overall = Progress+Regress+Repeat,
         Progressing = round(Progress/overall*100,1),
         Regressing = round(Regress/overall*100,1),
         Repeating = round(Repeat/overall*100,1),
         rank = Regressing) %>% 
  arrange(Regressing) %>% 
  gather(category, proportion, 6:8) %>% 
  ggplot(aes(x=reorder(subject_1, rank), y=proportion, fill = factor(category, levels = c("Progressing",
                                                                                              "Repeating", 
                                                                                              "Regressing")))) +
  geom_col(position = "stack") +
  coord_flip()+
  theme_bw() +
  theme(legend.title = element_blank()) +
  scale_y_continuous(breaks = seq(0,100, 10)) +
  geom_text(aes(label = paste0(proportion, '%')), position = position_stack(vjust = .5)) +
  labs(x="Subject area", 
       y="%", 
       title = "Figure 3: Proportion of FE school leavers by subject and progression status 2018-19")

#######################
###################################
#####################

test <- college_FE %>% filter(subject_1 == "Special Programmes")

college_FE %>% 
  filter(!is.na(sg_quintile)) %>% 
  group_by(sg_quintile, category) %>% 
  summarise(total=n()) %>% 
  spread(category,total) %>%
  mutate(overall =Progress+Regress+Repeat,
         Progressing = round(Progress/overall*100,1),
         Repeating = round(Repeat/overall*100,1),
         Regressing = round(Regress/overall*100,1)) %>% 
  gather("Status", "proportion", 6:8) %>% 
  ggplot(aes(x=sg_quintile, y=proportion, fill = factor(Status, levels = c("Progressing",
                                                                             "Repeating", 
                                                                             "Regressing")))) +
  geom_col(position = "stack") +
  coord_flip()+
  theme_bw() +
  theme(legend.title = element_blank()) +
  geom_text(aes(label = paste0(proportion, '%')), position = position_stack(vjust = .5)) +
  labs(x="SIMD Quintile", y="%", title = "Figure 4: Proportion of FE school leavers by SIMD and progression status", caption = "NOTE: Omits NAs") +
  scale_y_continuous(breaks = seq(0,100, 10))


