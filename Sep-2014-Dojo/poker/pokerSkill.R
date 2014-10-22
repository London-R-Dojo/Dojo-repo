library(MASS)

# Data taken from page 40-43 in the Mathematics of Poker
winrate<-100 * c(-0.05,-0.04,-0.03,-0.02,-0.01,0,0.01,0.02,0.03)
pb<-c(0.0025,0.02,0.08,0.2,0.395,0.2,0.08,0.02,0.0025)

table<-rbind(winrate,pb)
pbs = data.frame(t(table))

# This is based on the sample size and was not clear how it was calculated as we only had a few pages of the book
std = 1.61

observed.win.rate <- 1.15

p.a.given.b <- function(mean, std, obs.win.rate = 1.15) {
  pnorm(obs.win.rate + 0.01, mean = mean, sd = std) - pnorm(obs.win.rate - 0.01, mean = mean, sd = std)
}

pbs$pagb = apply(pbs[,1, drop = FALSE], 1, p.a.given.b, std, observed.win.rate)

pbs$pabbar<-NULL
for ( i in 1:nrow(pbs)) { 
  pbs$pabbar[i] <- sum( pbs$pagb[-i ]*pbs$pb[-i])/sum(pbs$pb[-i])
}

pbs$p.b<-1-pbs$pb

pbs$p.bayes<-with(pbs, pagb*pb/(pagb*pb+pabbar*p.b))

# How likely is it that this player is a winning player?
sum(pbs$p.bayes[pbs$winrate>=0])
