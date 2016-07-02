library(uplift)
library(dplyr)
library(caret)
##load the data
hillstrom <- read.csv("datasets/Hillstrom.csv")
str(hillstrom)

##change some of the ints to factors
hillstrom$mens <- as.factor(hillstrom$mens)
hillstrom$womens <- as.factor(hillstrom$womens)
hillstrom$newbie <- as.factor(hillstrom$newbie)
hillstrom$visit <- as.factor(hillstrom$visit)

str(hillstrom)

##conversion is a stronger outcome than visit
target <- 'conversion'

##treatment variable must be in binary format and take values 0/1
hillstrom <- hillstrom %>% mutate(treatment = ifelse(segment == 'No E-Mail', 0, 1))
hillstrom$segment <- NULL

### create a formula of all the predictor + treatment var against the target
predictors <- setdiff(names(hillstrom), c(target, 'treatment'))

formula <- reformulate(termlabels = c(predictors, 'trt(treatment)'), response = target)

explore(formula, hillstrom)

##Split training & testing
inTrain <- createDataPartition(hillstrom$conversion, p = 0.7, list = F)
hillstrom_train <- hillstrom[inTrain, ]
hillstrom_test <- hillstrom[-inTrain, ]

#Try out the different models in uplift package

fit_knn <- upliftKNN(hillstrom_train, hillstrom_test, hillstrom_train$conversion, hillstrom_train$treatment, k = 3)
summary(fit_knn)

plot_uplift <- function(model_fit) {
  pred <- predict(model_fit, hillstrom_test)
  uplift <- pred[, 1] - pred[, 2]
  with_predictions = data.frame(hillstrom_test, uplift)
  #modelProfile(reformulate(predictors, response = 'uplift_RF'), data = with_predictions, group_label = "D")
  
  perf <- performance(pred[, 1], pred[, 2], with_predictions$conversion, with_predictions$treatment)
  plot(perf[, 8] ~ perf[, 1], type ="l", xlab = "Decile", ylab = "uplift")
}

##modelProfile
plot_uplift(fit_knn)
