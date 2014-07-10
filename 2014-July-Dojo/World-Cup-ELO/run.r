# World Cup ELO ratings
#

# Source this file using source("run.r") from within an R session.
#
# Note: matches.csv must be in the working directory of the R process.
# The working directory can be set/got using setwd()/getwd().
#
# After it has finished running:
#   matches     contains the original data set
#   frame       contains the processed data set
#   ratings     contains the final team ratings (ordered by rating)
#

# Made at the R Coding dojo, 9th July 2014
# http://www.meetup.com/LondonR/events/193660332/
#
# Data set:
# https://github.com/mneedham/neo4j-worldcup/blob/master/data/matches.csv
#
# Rating system:
# http://eloratings.net/system.html
#

# for str_match()
library(stringr)

# get data set
matches <- read.csv(file="matches.csv",head=FALSE,sep=",")

# get overall number of goals scored by teams 1 and 2 (for each match)
tmp <- matches$V7
scores <- str_match(tmp, "^(\\d*):(\\d*)")
score1 <- strtoi(scores[,2])
score2 <- strtoi(scores[,3])

# create frame with
#   year (of match),
#   team1 and team2 (names),
#   score1 and score2,
#   team1win and team2win (Booleans - did the team win?), and
#   result (0 = team 1 lost, 0.5 = the teams drew, 1 = team 1 won)
#
frame <- data.frame(
    year=matches$V1,
    team1=matches$V2,
    team2=matches$V4,
    score1=score1,
    score2=score2,
    team1win=score1 > score2,
    team2win=score1 < score2,
    result=ifelse(score1 < score2, 0,
           ifelse(score1 > score2, 1,
                                   0.5)))

# get list of unique team names
teams = unique(c(as.character(frame$team1), as.character(frame$team2)))

# give each team an initial rating of zero
ratings <- data.frame(team=teams, rating=c(1:length(teams))*0)

# for each match
for (i in 1:length(frame$team1)) {

       # get team names
       t1 <- as.character(frame$team1[i])
       t2 <- as.character(frame$team2[i])

       # look up current rating for each team
       r1 <- ratings$rating[ratings$team==t1]
       r2 <- ratings$rating[ratings$team==t2]

       # calculate rating delta between teams
       dr <- r1 - r2

       # calculate predicted score (we*) and retrieve actual score (w*)
       we1 <- 1 / (10 ** (-dr/400) + 1)
       w1 <- frame$result[i]
       we2 <- 1 / (10 ** (dr/400) + 1)
       w2 <- 1 - w1

       # calculate new ratings for each team
       rn1 <- r1 + 100 * (w1 - we1)
       rn2 <- r2 + 100 * (w2 - we2)

       print(rn1)

       # save new ratings
       ratings$rating[ratings$team==t1] <- rn1
       ratings$rating[ratings$team==t2] <- rn2

       print(ratings$rating[ratings$team==t1])
       print(ratings$rating[ratings$team==t2])
}

# sort ratings frame by rating
ratings <- ratings[order(ratings$rating),]
