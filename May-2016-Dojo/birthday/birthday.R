
main <- function() {

n <- 100000

num.with.same.bday <- 3

system.time(pp <- rDojoSolution(n, num.with.same.bday))

}

rDojoSolution <- function(n, num.with.same.bday) {

  # Hacky code to try and simulate the extended birthday problem when we wnat to find
  # at least three people with the same birthday
  people <- vector(mode = 'integer', length = n)
  # Sample n sets of days of the year
  # Set 731 as it is 2*365 + 1, thus guaranteeing that at least three people will share a birthday
  days.in.year <- 365
  max.number.days <- (num.with.same.bday - 1)*days.in.year  + 1

  s1 = sample(1:days.in.year, max.number.days*n, replace = TRUE)

  for (i in 1:n){
    s = s1[(((i-1)*max.number.days)+1):(i*max.number.days)]
    for (j in 1:max.number.days){
      if (sum(s[1:j] == s[j]) == num.with.same.bday) {
        people[i] <- j
        break
      }
    }
  }

  mean(people)
}

