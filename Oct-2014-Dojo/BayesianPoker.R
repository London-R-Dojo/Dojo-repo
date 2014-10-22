library(rstan)

poker.skill <- '
data {
int<lower=0> J; 
real y[J]; // estimated treatment effects
}
parameters {
real mu; 
real<lower=0> sigma;
}
model {
mu ~ normal(-1, 4);
sigma ~ normal(0.15, 4);
y[J] ~ normal(mu, sigma);
}
'

n= 16900
poker_dat <- list(J = n, 
                  y = c(rnorm(n, 1.15, 0.05)),
                  sigma=c(rnorm(n, 1.61, 0.05)))

fit <- stan(model_code = poker.skill, data = poker_dat, 
            iter = 1000, chains = 4)

plot(fit)
3 - pnorm(0, mean = 0.39, sd = 2.76)
