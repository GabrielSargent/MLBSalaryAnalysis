library(tidyverse)
library(GGally)
library(car)
library(broom)

df <- read.csv("./data/processed/data.csv")

#This chunk transforms our response variable, salary, by first dividing each salary by the maximum salary for that year, so everything is a proportion. Then, the natural log operation removes skewness. It is a bit strange, but we can still look for a proportional relationship with our predictors

totallog <- df %>%
  group_by(yearID) %>%
  mutate(salprop = salary / max(salary, na.rm = TRUE)) %>%
  mutate(logsal = log(salprop))

head(totallog)



#This chunk is a correlation map using all of our possible predictors. The goal here is to use a VIF to show which predictors are best to use for predicting salary.

preds <- c("AB", "R", "H", "X2B", "X3B", "HR", "RBI", "SB", "CS", "BB", "SO", "IBB", "HBP", "SH", "GIDP", "Avg", "Slg", "OBP", "OPS")

predset <- totallog %>%
  select(any_of(preds)) %>%
  select(where(is.numeric)) %>%
  drop_na()

ggcorr(predset, method = c("everything", "pearson"), 
       label = FALSE, label_round = 2, hjust = 0.9, layout.exp = 1) +
  ggtitle("Predictors correlation heatmap")



#Here, I will make a linear model using some predictors that I am interested in. The important thing is to not use predictors that are too highly correlated with each other based on this heatmap. I will use a VIF to verify that there is not too much multicollinearity in my predictors.

sallm <- lm(logsal ~ OPS + SO + SB + RBI + BB + IBB, data=totallog)

vif(sallm)

