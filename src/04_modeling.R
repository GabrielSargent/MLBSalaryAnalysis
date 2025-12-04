#Import data
data <- read.csv("./data/processed/data_with_prop.csv")

#Do log transform on max salary ratio
data[,"log_max_sal_ratio"] <- log(data$max_sal_prop)

#Fit a linear model using Hits, Walks, Strikeouts, RBI, Batting Average, and OPS
fit <- lm(log_max_sal_ratio ~ H+BB+SO+RBI+Avg+OPS, data = data)
#The R summary tests the significance of each individual predictor, as well
#as an F-test for the whole model.
summary(fit)
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

#Lets do an F-test for a subset of the predictors: OPS, SO, and BB
X <- as.matrix(cbind("intercept"=rep(1, nrow(data)), data[,c("H", "BB", "SO", "RBI", "Avg", "OPS")]))
y <- as.matrix(data$log_max_sal_ratio)
C <- matrix(c(0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,1), nrow = 3)
d <- matrix(c(0,0,0), nrow = 3)
f_test_RSS(X, y, C, d)
