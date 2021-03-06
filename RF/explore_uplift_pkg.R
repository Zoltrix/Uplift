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

##RF

###RF, split_method = Chisq
fit_RF_Chisq <- upliftRF(formula, hillstrom_train, split_method="Chisq")
summary(fit_RF_Chisq)

###RF, split_method = ED (Eucledian Dist)
fit_RF_ED <- upliftRF(formula, hillstrom_train, split_method="ED")
summary(fit_RF_ED)


###RF, split_method = KL (Kullback-Leibler divergence)
fit_RF_KL <- upliftRF(formula, hillstrom_train, split_method="KL")
summary(fit_RF_KL)


###RF, split_method = Int (Interaction method)
fit_RF_Int <- upliftRF(formula, hillstrom_train, split_method="Int")
summary(fit_RF_Int)

plot_uplift <- function(model_fit) {
  pred_RF <- predict(model_fit, hillstrom_test)
  uplift_RF <- pred_RF[, 1] - pred_RF[, 2]
  with_predictions = data.frame(hillstrom_test, uplift_RF)
  #modelProfile(reformulate(predictors, response = 'uplift_RF'), data = with_predictions, group_label = "D")
  
  perf <- performance(pred_RF[, 1], pred_RF[, 2], with_predictions$conversion, with_predictions$treatment)
  plot(perf[, 8] ~ perf[, 1], type ="l", xlab = "Decile", ylab = "uplift")
}

##modelProfile
plot_uplift(fit_RF_KL)
plot_uplift(fit_RF_Chisq)
plot_uplift(fit_RF_ED)
plot_uplift(fit_RF_Int)
