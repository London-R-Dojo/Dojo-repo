require('ggplot2')

# set the full path here:
ebola <-read.csv("{{set full path here}}/Ebola - Countries.csv")

head(ebola)


ggplot(ebola,aes(x=Day,y=GuinSus))+geom_point() + ggtitle("Suspected cases in Guinea")

ebola$death.per.day=c(0,diff(ebola$GuinSus))
ggplot(ebola,aes(x=Day,y=death.per.day))+geom_point() + ggtitle("Deaths per day in Guinea")
ggplot(ebola,aes(x=Day,y=death.per.day))+geom_point() + ggtitle("Deaths per day in Guinea") + stat_smooth()

# Compute total suspected cases
ebola$totsus = ebola$GuinSus + ebola$LibSus + ebola$NigSus + ebola$SLSus + ebola$SenSus
ggplot(ebola,aes(x=Day,y=totsus))+geom_point()+stat_smooth() + ggtitle("Total suspected cases")

ggplot(ebola,aes(x=Day)) + 
  geom_point(aes(y=totsus, colour = "Total")) +
  geom_point(aes(y=GuinSus, colour = "Guinea")) + 
  scale_y_log10() +
  ggtitle("Suspected in Total and Guinea")

# create a simple linear model (~ is the 'equals' sign in an equation)
mod = lm( log(ebola$totsus) ~ ebola$Day )
# add a new column to the table containing the predicted total cases for that day using our model
ebola$predicted = exp(c(0,predict(mod)))

ggplot(ebola,aes(x=Day)) +
  geom_point(aes(y=totsus, colour = "Total")) +
  geom_point(aes(y=predicted, colour = "Predicted")) +
  scale_y_log10() +
  ggtitle("Total and Predicted")


# extrapolate
intercept=mod$coefficients[1]
slope=mod$coefficients[2]

# expess our model as a function that returns the predicted cases up to any given day
prd=function(d) {
  exp(intercept + d*slope)
}

# on day 200, how many?
prd(200)

# Create a doomsday function
days.until.end.of.humanity = function(totd) {
  (log(totd)-intercept) / slope
}

# Discover how long we have left
days.until.end.of.humanity(6e9)

# THE END (all dead)
