data <- as.data.frame(read.csv("./data/processed/data.csv")) 

# Find and store the maximum salary for each year we havedata for
max_salaries <- rep(0,31)
names(max_salaries) <- c(1985:2015)
for(i in 1985:2015){
  max_salaries[as.character(i)] <- max(data[which(data$yearID == i), "salary"])
}

# Now create max_salary_prop by dividing each salary by the maximum salary in that year
max_sal_prop <- rep(0, nrow(data))
for(i in 1:nrow(data)){
  year <- data$yearID[i]
  max_sal <- max_salaries[as.character(year)]
  max_sal_prop[i] <- data$salary[i]/max_sal
}
data$max_sal_prop <- max_sal_prop # Add it to our dataset
write.csv(data, file = "./data/processed/data_with_prop.csv")# Export it

# Notice that if we plot salary against year, the mean and variance of the salaries grow over time
plot(data$yearID, data$salary, main = "Salaries by year", xlab = "year", ylab = "salaries ($)")
# If we instead use the proportion of the max, the distribution is similar between years
plot(data$yearID, data$max_sal_prop, main = "Salary:Max Salary by year", xlab = "year", ylab = "ratio of salary to max salary of that year")

# We will also need to transform this new response. Note how left-skewed it is:
hist(data$max_sal_prop, freq = F, main = "Histogram of max salary proportion", xlab = "max salary proportion")
# Try a Box-Cox using all potential predictors
bc <- MASS::boxcox(max_sal_prop ~ AB+R+H+X2B+X3B+HR+RBI+SB+CS+BB+SB+IBB+SH+SF+GIDP+Avg+OPS, data = data)
(lambda <- bc$x[which.max(bc$y)]) # Best lambda is -0.02020202

# This looks much better
hist(((data$max_sal_prop)^lambda-1)/lambda, freq = F,
     main = "Histogram after Box-Cox", xlab = "((max salary proportion)^lambda-1)/lambda")
# However, our power is very close to 0. We might consider simply doing a log transformation
hist(log(data$max_sal_prop), freq = F,
     main = "Histogram after Log Transformation", xlab = "log(max salary proportion)")
