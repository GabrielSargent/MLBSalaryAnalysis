#Import data
data <- read.csv("./data/processed/data_with_prop.csv")

#Do log transform on max salary ratio
data[,"log_max_sal_ratio"] <- log(data$max_sal_prop)

#Fit a linear model using Walks, Strikeouts, singles, RBI, OPS, and intentional walks.
#This is based on the previous VIF analysis
fit <- lm(log_max_sal_ratio ~ BB+SO+SB+RBI+OPS+IBB, data = data)
#The R summary tests the significance of each individual predictor, as well
#as an F-test for the whole model.
(fit_summary <- summary(fit))
write.csv(fit_summary$coefficients, "./results/Model/fit_summary.csv")
plot(fit)

#Some functions from the hw to help with the F test
find_beta <- function(X, y){
  Xqr <- qr(X)
  return(qr.coef(Xqr, y))
}

find_betaH <- function(X, y, C, d){
  betahat <- find_beta(X, y)
  XtX_inv <- solve(t(X) %*% X)
  betahatH <- betahat + (
    XtX_inv %*% t(C) %*% solve(C %*% XtX_inv %*% t(C)) %*% (d - (C %*% betahat))
  )
  return(betahatH)
}

f_test_RSS <- function(X, y, C, d){
  n <- nrow(X); p <- ncol(X); q <- nrow(C)
  
  betahat <- find_beta(X, y)
  betahatH <- find_betaH(X, y, C, d)
  
  RSS <- sum((y-X%*%betahat)^2)
  RSSH <- sum((y-X%*%betahatH)^2)
  Fstat <- ((RSSH-RSS)/q)/(RSS/(n-p))
  pval <- pf(Fstat, q, n-p, lower.tail = F)
  return(c("F" = Fstat, "P-Value" = pval))
}

#Lets do an F-test for all predictors
X <- as.matrix(cbind("intercept"=rep(1, nrow(data)), data[,c("BB", "SO", "SB", "RBI", "OPS", "IBB")]))
y <- as.matrix(data$log_max_sal_ratio)

C <- as.matrix(cbind(rep(0, ncol(X)-1), diag(nrow = ncol(X)-1)))
d <- rep(0, 6)
f_test_RSS(X, y, C, d)

#Lets do an F-test for a subset of the predictors: OPS, SO, and BB
C <- matrix(c(0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0), nrow = 3)
d <- matrix(c(0,0,0), nrow = 3)
f_test_RSS(X, y, C, d)
