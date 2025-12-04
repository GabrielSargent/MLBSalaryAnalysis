#Import data
data <- read.csv("./data/processed/data_with_prop.csv")

#Do log transform on max salary ratio
data[,"log_max_sal_ratio"] <- log(data$max_sal_prop)

preds <- c("BB", "SO", "SB", "RBI", "OPS", "IBB")
R2_vals <- rep(0, length(preds))
names(R2_vals) <- preds
for(pred in preds){
  fit <- lm(data$log_max_sal_ratio ~ 0+data[,pred])
  fit_summary <- summary(fit)
  R2_vals[pred] <- fit_summary$r.squared
}
(R2_vals)
