library(RTextTools)
library(data.table)

data(NYTimes)
ny <- data.table(NYTimes)

# train.index <- sample(seq(1,nrow(ny)), nrow(ny)*2/3)
predict.column <- "Subject"
ny_matrix <- create_matrix(ny[[predict.column]], language="english", removeNumbers = TRUE, stemWords = TRUE, removeSparseTerms = 0 )

train.size  <- 2000
test.size <- 1000
nyc <- create_container(ny_matrix, ny[["Topic.Code"]], trainSize = 1:train.size, testSize = (train.size+1):(train.size+test.size), virgin = FALSE)
# nyc <- create_container(ny_matrix, ny[["Topic.Code"]], trainSize = 1:100, testSize = 101:202, virgin = FALSE)

trained.svm <- train_model(nyc, "SVM")
trained.glmet <- train_model(nyc, "GLMNET")
trained.maxent <- train_model(nyc, "MAXENT")
trained.slda <- train_model(nyc, "SLDA")
trained.boosting <- train_model(nyc, "BOOSTING")
# trained.bagging <- train_model(nyc, "BAGGING")
trained.rf <- train_model(nyc, "RF")
trained.nnet <- train_model(nyc, "NNET")
trained.tree <- train_model(nyc, "TREE")

classify.svm <- classify_model(nyc, trained.svm)
classify.glmet <- classify_model(nyc, trained.glmet)
classify.maxent <- classify_model(nyc, trained.maxent)
classify.slda <- classify_model(nyc, trained.slda)
classify.boosting <- classify_model(nyc, trained.boosting)
# classify.bagging <- classify_model(nyc, trained.bagging)
classify.rf <- classify_model(nyc, trained.rf)
classify.nnet <- classify_model(nyc, trained.nnet)
classify.tree <- classify_model(nyc, trained.tree)

analytics <- create_analytics(nyc, cbind(classify.svm, 
                                         classify.glmet,
                                         classify.maxent, 
                                         classify.slda, 
                                         classify.boosting, 
                                         #                                          classify.bagging,
                                         classify.rf,
                                         classify.nnet,
                                         classify.tree) )

