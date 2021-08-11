library(tidyverse)



regression1<- college_FE %>% 
  filter(college_name2 != "Newbattle Abbey College",
         college_name2 != "Sabhal Mor Ostaig") %>% 
  group_by(college_name2, category) %>%
  summarise(total = n()) %>% 
  spread(category, total) %>% 
  mutate(total = Progress+Regress+Repeat,
         progressperc=round(Progress/total*100,1)) %>% 
  select(college_name2, progressperc)

regression2 <- college_FE %>% 
  filter(college_name2 != "Newbattle Abbey College",
         college_name2 != "Sabhal Mor Ostaig") %>% 
  group_by(college_name2, sg_quintile) %>%
  summarise(total = n()) %>% 
  spread(sg_quintile, total) %>% 
  select(college_name2:`5`) %>% 
  mutate(total = `1`+`2`+`3`+`4`+`5`,
         simd10=round(`1`/total*100,1)) %>% 
  select(college_name2, simd10)

regression3 <- college_FE %>% 
  filter(college_name2 != "Newbattle Abbey College",
         college_name2 != "Sabhal Mor Ostaig") %>% 
  group_by(college_name2, stem_subject) %>%
  summarise(total = n()) %>% 
  spread(stem_subject, total) %>% 
  mutate(total = No+Yes,
         STEM=round(Yes/total*100,1)) %>% 
  select(college_name2, STEM)


##############################################
regressionmerged <- merge(regression1, regression2, by='college_name2')
regressionmergedd <- merge(regressionmerged, regression3, by='college_name2')
############################################

ggplot(regressionmergedd, aes(x=simd10, y=progressperc))+
  geom_point()+
  stat_smooth(method = 'lm') +
  theme_bw()

ggplot(regressionmergedd, aes(x=STEM, y=progressperc))+
  geom_point()+
  geom_smooth(method = 'lm')
  theme_bw()
  ############################################
  
library(caret)

model <- lm(progressperc~STEM+simd10, data= regressionmergedd)

summary(model)$coef

newdata <- data.frame(STEM = c(0,10,20,30,40))

model %>% predict(newdata)

summary(model)
