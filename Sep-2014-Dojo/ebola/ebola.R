require('ggplot2')

run <- function() {

  # set the full path here:
  ebola <-read.csv("{{set full path here}}/Ebola - Countries.csv")

  head(ebola)

  exploratoryPlots(ebola)

  mod <- linearModel(ebola)

  ebola <- addPredictedValues(ebola, mod)

  # extrapolate
  intercept=mod$coefficients[1]
  slope=mod$coefficients[2]

  prd(200)

  # Discover how long we have left
  days.until.end.of.humanity(6e9)

  # THE END (all dead)
}

exploratoryPlots <- function(ebola) {
  print(ggplot(ebola,aes(x=Day,y=GuinSus))+geom_point() + ggtitle("Suspected cases in Guinea"))

  ebola$death.per.day=c(0,diff(ebola$GuinSus))
  print(ggplot(ebola,aes(x=Day,y=death.per.day))+geom_point() + ggtitle("Deaths per day in Guinea"))
  print(ggplot(ebola,aes(x=Day,y=death.per.day))+geom_point() + ggtitle("Deaths per day in Guinea") + stat_smooth())

  print(ggplot(ebola,aes(x=Day,y=totsus))+geom_point()+stat_smooth() + ggtitle("Total suspected cases"))

  print(ggplot(ebola,aes(x=Day)) + 
  geom_point(aes(y=totsus, colour = "Total")) +
  geom_point(aes(y=GuinSus, colour = "Guinea")) + 
  scale_y_log10() +
  ggtitle("Suspected in Total and Guinea"))
}


computeTotalCases <- function(ebola) {
  # Compute total suspected cases
  ebola$totsus = ebola$GuinSus + ebola$LibSus + ebola$NigSus + ebola$SLSus + ebola$SenSus
  ebola
}
linearModel <- function(ebola) {
  # create a simple linear model (~ is the 'equals' sign in an equation)
  mod = lm( log(ebola$totsus) ~ ebola$Day )
}

addPredictedValues <- function(ebola, mod) {
  # add a new column to the table containing the predicted total cases for that day using our model
  ebola$predicted = exp(c(0,predict(mod)))
  ebola
}

plotPredictedVsActual <- function(ebola) {
  ggplot(ebola,aes(x=Day)) +
  geom_point(aes(y=totsus, colour = "Total")) +
  geom_point(aes(y=predicted, colour = "Predicted")) +
  scale_y_log10() +
  ggtitle("Total and Predicted")
}

# # expess our model as a function that returns the predicted cases up to any given day
prd=function(d, intercept, slope) {
  exp(intercept + d*slope)
}

# Create a doomsday function
days.until.end.of.humanity = function(totd, intercept, slope) {
  (log(totd)-intercept) / slope
}

