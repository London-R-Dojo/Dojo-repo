# http://www.mrc-bsu.cam.ac.uk/bugs/winbugs/Vol1.pdf
# Page 3: Rats
data {
  int<lower=0> N;
  int<lower=0> T;
  real x[T];
  real y[N,T];
  real xbar;
}
parameters {
  real alpha[N];
  real beta[N];

  real<lower=0> sigmasq_y;
}
transformed parameters {
  real<lower=0> sigma_y;       // sigma in original bugs model
  sigma_y <- sqrt(sigmasq_y);
}
model {
  sigmasq_y ~ inv_gamma(0.001, 0.001);
  alpha ~ normal(0, 100); // vectorized
  beta ~ normal(0, 100);  // vectorized
  for (n in 1:N)
    for (t in 1:T) 
      y[n,t] ~ normal(alpha[n] + beta[n] * (x[t] - xbar), sigma_y);

}
