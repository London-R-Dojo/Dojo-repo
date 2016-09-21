library(rstan)
library(ggplot2)
library(data.table)
library(tidyr)


main <- function() {

  y <- read.table("rats.txt", header = TRUE)
  x <- c(8, 15, 22, 29, 36)
  xbar <- mean(x)
  colnames(y) <- x

  N <- nrow(y)
  T <- ncol(y)
  rats_fit <- stan(file = "rats.stan")
  print(rats_fit)
  plot(rats_fit)
  summary(rats_fit)



  tt <- 8
  rat.number <- 1

  printRatNumAt <- function(rat.number, tt, rats_fit = rats_fit) {
    #   group.dist= data.frame( mu_alpha = extract(rats_fit, "mu_alpha"), 
    #                          mu_beta = extract(rats_fit, "mu_beta"))
    #   group.dist <- data.table(group.dist)
    #     group.dist[, groupYatTT := mu_alpha + (tt - xbar)*mu_beta]

    rat.dist <- data.table(data.frame( alpha = extract(rats_fit, paste0("alpha[", rat.number, "]")), 
                                      beta = extract(rats_fit, paste0("beta[", rat.number, "]"))))
    setnames(rat.dist, c("alpha", "beta"))
    rat.dist[, ratYatTT := alpha + beta * (tt - xbar)]
    actual.at.tt <- y[rat.number, which(x == tt)]


    print(
          #           ggplot(group.dist, aes(groupYatTT)) + geom_density(color = "blue") + 
          ggplot() +  geom_density(data = rat.dist, aes(ratYatTT)) + geom_vline(xintercept = actual.at.tt) + ggtitle(paste("Rat:", rat.number, "at", tt, " group mu, sd:", mean(group.dist$groupYatTT), sd(group.dist$groupYatTT), " rat mu, sd:", mean(rat.dist$ratYatTT), sd(rat.dist$ratYatTT))))

  }

  printRatNumAt(1,8)
  printRatNumAt(2,8)
  printRatNumAt(2,36)



}


