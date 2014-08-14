# install.packages('caret')
# install.packages('mlbench')
# install.packages(''pROC')
# install.packages('pls')
# install.packages('randomForest')

library(caret)
library(mlbench)

# data prep
data(Sonar)
set.seed(107)
inTrain <- createDataPartition(y = Sonar$Class,
                               p = .75,
                               list = FALSE)

training <- Sonar[inTrain,]
testing <- Sonar[-inTrain,]

# set control parameters
ctrl <- trainControl(method = "repeatedcv",
                     repeats = 3,
                     classProbs = TRUE,
                     summaryFunction = twoClassSummary)

# train partial least squares classifier
system.time(plsFit <- train(Class ~ .,
                            data = training,
                            method = "pls",
                            tunelength = 15,
                            trControl = ctrl,
                            metric = 'ROC',
                            preProc = c("center", "scale")))

# train random forest classifier
system.time(rfFit <- train(Class ~ .,
                            data = training,
                            method = "rf",
                            tunelength = 15,
                            trControl = ctrl,
                            metric = 'ROC',
                            preProc = c("center", "scale")))

# test classifiers
plsClasses <- predict(plsFit, newdata = testing)
plsProbs <- predict(plsFit, newdata = testing, type = "prob")

rfClasses <- predict(rfFit, newdata = testing)
rfProbs = predict(rfFit, newdata = testing, type = 'prob')

# results
confusionMatrix(plsClasses, testing$Class) # 74% accuracy
confusionMatrix(rfClasses, testing$Class) # 84% accuracy (random forest wins!)
