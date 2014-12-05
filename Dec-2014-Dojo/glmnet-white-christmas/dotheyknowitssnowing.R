library(glmnet) 
library(weatherData­) 
library(data.table)­ 
dates=seq(as.Date("­1995-01-01"), as.Date("2013-01-01"), by=365) 

x = vector("list", length(dates)) 
for(i in seq_along(x)) x[[i]] = 
getWeatherForDate("EGLL"­,dates[[i]], 
min(dates[[i]]+366, as.Date("2014-12-02")) 
, opt_all_columns=TRUE) 

w = do.call("rbind", x) 
w$Date = as.Date(w$Date) 
weather = data.table(w, key="Date") 


#weather<-getWea­therForDate("EGLL","2000­-12-01","2014-12-02",opt­_all_columns=TRUE) 

#checkDataAvailabil­ityForDateRange("LHR","1­990-12-01","2014-12-02")­ 

weather$Events<-­gsub("^$","Sun",weather$­Events) 
weather$y = grepl("[sS]now", weather$Events) 
#sapply(weather, function(x) sum(is.na(x))) 
weather$Max_Gust_Sp­eedKm_h = NULL 
table(complete.case­s(weather)) 
weather = na.omit(weather) 

cols = sapply(weather, is.numeric) 
x = as.matrix(weather[,cols,­ with=FALSE]) 

ylag = weather$y[-length(weathe­r$y)] 
xlag = x[-1,] 


cv = cv.glmnet(xlag, ylag, family="binomial") 
plot(cv) 
m = glmnet(xlag, ylag, lambda=cv$lambda.1se, family="binomial") 
coef(m) 
weather[nrow(x),] 
todayodds<-exp(p­redict(m, xlag[rep(nrow(xlag), each=2),])) 

which(ylag==1) 
yhat<-exp(predic­t(m,xlag )) 

# yhat <- yhat/(1-yhat) 
y.hat = data.frame(yhat, ylag) 

library(ggplot2) 
ggplot(y.hat, aes(s0)) + geom_bar(binwidth = 0.05) + facet_grid(ylag ~ ., scales = "free") 

with(y.hat, table(ylag, s0>1)) 
hist(exp(predict(m,­ xlag))) 
str(m) 
plot(m) 
summary(m) 
plot(m) 

