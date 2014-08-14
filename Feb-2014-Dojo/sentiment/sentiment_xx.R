#=======================================================================================
## ON windows, we need to dowload the certificate for OAUTH
## NOTE:  you will need to setup an app on Twitter
## dev.twitter.com <- get your KEY/SECRET
#=======================================================================================


##########################################################################
## Load packages
##########################################################################

library(twitteR)
library(ROAuth)


## Windows users need to get this file
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")



##########################################################################
## Authenticate with Twitter
##########################################################################

## authenticate with the API
## requires that you have registered an app
KEY <- "XXXXXX put yours XXXXXXXXX"
SECRET <-"XXXXXX put yours XXXXXXXXX"


## create an object that will save the authenticated onbject -- we can for later sessions
## will need to navigate to website and type in data to generate the file
## NOTE:  Only need to do this part once!!!
cred <- OAuthFactory$new(consumerKey = KEY, 
                         consumerSecret = SECRET,
                         requestURL = "https://api.twitter.com/oauth/request_token", 
                         accessURL = "https://api.twitter.com/oauth/access_token", 
                         authURL = "https://api.twitter.com/oauth/authorize")
cred$handshake(cainfo="cacert.pem")


## load the cred object in later sessions and simply pass to the registerTwitterOAuth
## After this file is saved, you only need to load the cred object back into memory
save(cred, file="twitter authentication.Rdata")


## Authenticate with Twitter = this is an important peice of code
registerTwitterOAuth(cred)


##########################################################################
## lets test out what our session limits look like
##########################################################################
rate.limit <- getCurRateLimitInfo( cainfo="cacert.pem")
rate.limit

delta.tweets=searchTwitter('@delta',n=1500,cainfo="cacert.pem")

delta.text = laply(delta.tweets, function(t) t$getText() )
## If return 350, Authenticated session = more API calls allowed / hour
rate.limit$hourlyLimit
rate.limit$remainingHits
rate.limit$resetTime


american.tweets=searchTwitter('@AmericanAir',n=1500,cainfo="cacert.pem")
tweet=american.tweets[[1]]
class(tweet)
tweet$getScreenName()
tweet$getText()
american.text = laply(american.tweets, function(t) t$getText())
## If return 350, Authenticated session = more API calls allowed / hour
rate.limit$hourlyLimit
rate.limit$remainingHits
rate.limit$resetTime

jetblue.tweets=searchTwitter('@JetBlue',n=1500,cainfo="cacert.pem")
tweet=jetblue.tweets[[1]]
class(tweet)
tweet$getScreenName()
tweet$getText()
jetblue.text = laply(jetblue.tweets, function(t) t$getText())
## If return 350, Authenticated session = more API calls allowed / hour
rate.limit$hourlyLimit
rate.limit$remainingHits
rate.limit$resetTime

southwest.tweets=searchTwitter('@SouthwestAir',n=1500,cainfo="cacert.pem")
tweet=southwest.tweets[[1]]
class(tweet)
tweet$getScreenName()
tweet$getText()
southwest.text = laply(southwest.tweets, function(t) t$getText())
## If return 350, Authenticated session = more API calls allowed / hour
rate.limit$hourlyLimit
rate.limit$remainingHits
rate.limit$resetTime

usairways.tweets=searchTwitter('@USAirways',n=1500,cainfo="cacert.pem")

tweet=usairways.tweets[[1]]
class(tweet)
tweet$getScreenName()
tweet$getText()
us.text = laply(usairways.tweets, function(t) t$getText())
## If return 350, Authenticated session = more API calls allowed / hour
rate.limit$hourlyLimit
rate.limit$remainingHits
rate.limit$resetTime

united.tweets=searchTwitter('@United',n=1500,cainfo="cacert.pem")

tweet=united.tweets[[1]]

class(tweet)

tweet$getScreenName()
tweet$getText()

united.text = laply(united.tweets, function(t) t$getText())
## If return 350, Authenticated session = more API calls allowed / hour
rate.limit$hourlyLimit
rate.limit$remainingHits
rate.limit$resetTime


hu.liu.pos=scan('C:/Users/uzink/Desktop/Sentiment/dictionnary/positive-words.txt',what='character',comment.char=';')
hu.liu.neg=scan('C:/Users/uzink/Desktop/Sentiment/dictionnary/negative-words.txt',what='character',comment.char=';')

score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{
  require(plyr)
  require(stringr)
  
  # we got a vector of sentences. plyr will handle a list
  # or a vector as an "l" for us
  # we want a simple array of scores back, so we use
  # "l" + "a" + "ply" = "laply":
  scores = laply(sentences, function(sentence, pos.words, neg.words) {
    
    # clean up sentences with R's regex-driven global substitute, gsub():
    sentence = gsub('[[:punct:]]', '', sentence)
    sentence = gsub('[[:cntrl:]]', '', sentence)
    sentence = gsub('\\d+', '', sentence)
    # and convert to lower case:
    sentence = tolower(sentence)
    
    # split into words. str_split is in the stringr package
    word.list = str_split(sentence, '\\s+')
    # sometimes a list() is one level of hierarchy too much
    words = unlist(word.list)
    
    # compare our words to the dictionaries of positive & negative terms
    pos.matches = match(words, hu.liu.pos)
    neg.matches = match(words, hu.liu.neg)
    
    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:
    pos.matches = !is.na(pos.matches)
    neg.matches = !is.na(neg.matches)
    
    # and conveniently enough, TRUE/FALSE will be treated as 1/0 by sum():
    score = sum(pos.matches) - sum(neg.matches)
    
    return(score)
  }, pos.words, neg.words, .progress=.progress )
  
  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}


#Algorithm sanity check
#Let's quickly test our score.sentiment() function and word lists with some sample sentences:
sample = c("You're awesome and I love you",
               "I hate and hate and hate. So angry. Die!",
               "Impressed and amazed: you are peerless in your
achievement of unparalleled mediocrity.")

result = score.sentiment(sample, pos.words, neg.words)
class(result)
result$score

delta.scores=score.sentiment(delta.text, pos.words,neg.words, .progress='text')
delta.scores$airline='Delta'
delta.scores$code='DL'

american.scores=score.sentiment(american.text, pos.words,neg.words, .progress='text')
american.scores$airline='American'
american.scores$code='AA'

jetblue.scores=score.sentiment(jetblue.text, pos.words,neg.words, .progress='text')
jetblue.scores$airline='JetBlue'
jetblue.scores$code='JB'

southwest.scores=score.sentiment(southwest.text, pos.words,neg.words, .progress='text')
southwest.scores$airline='SouthWest'
southwest.scores$code='SW'

united.scores=score.sentiment(united.text, pos.words,neg.words, .progress='text')
united.scores$airline='United'
united.scores$code='UA'

us.scores=score.sentiment(us.text, pos.words,neg.words, .progress='text')
us.scores$airline='USAir'
us.scores$code='US'

hist(delta.scores$score)
library(ggplot2)
qplot(delta.scores$score)

all.scores = rbind(american.scores, delta.scores, jetblue.scores, southwest.scores, united.scores, us.scores )

#compare scores
g = ggplot(data=all.scores, mapping=aes(x=score, fill=aigrrline) )
g = g + geom_bar(binwidth=1)
g = g + facet_grid(airline~.)
g = g + theme_bw() + scale_fill_brewer(palette=2)
g

#Ignore the middle
#Let's create two new boolean columns to focus on tweets with very negative (score <= -2) and very positive (score >= 2) sentiment scores:

all.scores$very.pos.bool = all.scores$score >= 2
all.scores$very.neg.bool = all.scores$score <= -2

all.scores[c(1,6,47,99), c(1, 3:6)]

#We want to count the occurrence of these these strong sentiments for each airline. We can easily cast these TRUE/FALSE values to numeric 1/0, so we can then use sum() to count them:
  
all.scores$very.pos = as.numeric( all.scores$very.pos.bool )
all.scores$very.neg = as.numeric( all.scores$very.neg.bool )

all.scores[c(1,6,47,99), c(1, 3:8)]

#We can use plyr's ddply() function to aggregate the rows for each airline, calling the summarise() function to create new columns containing the counts:
  
twitter.df = ddply(all.scores, c('airline', 'code'), 
                   summarise,very.pos.count=sum( very.pos ),
                   very.neg.count=sum( very.neg ) )

#As a single, final score for each airline, let's calculate the percentage of these "extreme" tweets which are positive:
  
  
twitter.df$very.tot = twitter.df$very.pos.count +
  twitter.df$very.neg.count

twitter.df$score = round( 100 * twitter.df$very.pos.count /
                              twitter.df$very.tot )

#The orderBy() function from the doBy package makes it easy to sort the results. Note that it preserves the original row names:
library(doBy)  
orderBy(~-score, twitter.df)

#Scrape the ACSI web site
library (XML)

#We specify which=1 to retrieve only the first table on the page, and header=T to indicate that the table headings should be used as column names:

acsi.url = 'http://www.theacsi.org/index.php?option=com_content&view=article&id=147&catid=&Itemid=212&i=Airlines'
acsi.df = readHTMLTable(acsi.url, header=T, which=1, stringsAsFactors=F)

#Since we are only interested in the most recent results, we only need to keep the first column (containing the airline names) and the nineteenth (containing 2011's scores):
  
acsi.df = acsi.df[,c(1,21)]

#Unfortunately, the headings in the original HTML table do not make very good column names, but they are easy to change:
    
colnames(acsi.df)
colnames(acsi.df) = c('airline', 'score')
colnames(acsi.df)

acsi.df$code = c('JB', "SW", NA, NA, 'DL', 'AA', 'US', 'UA', 'CO','NW')

#As some final clean up, add two-letter airline codes and ensure that the scores are treated as numbers:

acsi.df$score = as.numeric(acsi.df$score)

acsi.df

#The "NAs introduced by coercion" warning message indicates that the now-defunct Northwest's score of "#" couldn't be translated into a number, so R changed it to NA (as in "not applicable"). R was built with real data in mind, so its support of NA values is robust and (nearly) universal.


acsi.df

#Compare Twitter results with ACSI scores
#In order to compare our Twitter results with the ACSI scores, let's construct a new data.frame which contains both. The merge() function joins together two data.frames using common fields (as specified with the by parameter). Columns with different data but conflicting names (like our two "scores" columns) can be renamed according to the suffixes parameter:
  
compare.df = merge(twitter.df, acsi.df, by=c('code', 'airline'),
                       suffixes=c('.twitter', '.acsi'))
compare.df

#Graph the results
#We will again use ggplot2 to display our results, this time on a simple scatter plot. We will plot our Twitter score along the x-axis (x=score.twitter), the ACSI customer satisfaction index along the y (y=score.acsi), and will use color to distinguish the airlines (color=airline):
  

g = ggplot( compare.df, aes(x=score.twitter, y=score.acsi) ) +
  geom_point( aes(color=airline), size=5 ) +
  theme_bw() + theme ( legend.position=c(0.2, 0.85) )

g

#Like R itself, ggplot2 was built for performing analyses, so it can do a lot more than just display data. Adding a geom_smooth() layer will compute and overlay a running average of your data. But specify method="lm" and it will automatically run a linear regression and plot the best fitting model (lm() is R's linear modeling function):
  
g = g + geom_smooth(aes(group=1), se=F, method="lm")
g
