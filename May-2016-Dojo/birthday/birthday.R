library(Rcpp)

main <- function() {
  n <- 100000
  num.with.same.bday <- 3

  system.time(p1 <- rDojoSolution(n, num.with.same.bday))
  system.time(p2 <- rDojo.plusYearDayVector(n, num.with.same.bday))
  system.time(p3 <- rDojo.plusYearDayVector.cpp(n, num.with.same.bday))
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

rDojo.plusYearDayVector <- function(n, num.with.same.bday) {

  people <- vector(mode = 'integer', length = n)
  days.in.year <- 365
  max.number.days <- (num.with.same.bday - 1)*days.in.year  + 1
  all.samples = sample(1:days.in.year, max.number.days*n, replace = TRUE)

  for (i in 1:n){
    this.sample = all.samples[(((i-1)*max.number.days)+1):(i*max.number.days)]
    birthdaysOnDayOfYear <- rep(0, days.in.year)

    for (j in 1:max.number.days){
      bday <- this.sample[j]
      birthdaysOnDayOfYear[bday] <- birthdaysOnDayOfYear[bday] + 1
      if(birthdaysOnDayOfYear[bday] == num.with.same.bday) {
        people[i] <- j
        break
      }
    }
  }

  mean(people)
}

rDojo.plusYearDayVector.cpp <- function(n, num.with.same.bday) {
  people <- vector(mode = 'integer', length = n)
  # Sample n sets of days of the year
  # Set 731 as it is 2*365 + 1, thus guaranteeing that at least three people will share a birthday
  days.in.year <- 365
  max.number.days <- (num.with.same.bday - 1)*days.in.year  + 1
  all.samples = sample(1:days.in.year, max.number.days*n, replace = TRUE)

  simulatePeopleNeeded(all.samples, n, max.number.days, num.with.same.bday, days.in.year)
}

cppFunction('
            double simulatePeopleNeeded(IntegerVector samples, int iterations, int maxNumDays, int numSameBDay, int daysInYear) {
              IntegerVector peopleNeededInIteration = IntegerVector(iterations, 0);

              for(int i = 0; i < iterations; i++) {
                int sampleStartInd = i*maxNumDays;
                IntegerVector birthdaysOnDay = IntegerVector(daysInYear, 0);
                for(int j = 0; j < maxNumDays; j++) {
                  int bday = samples[sampleStartInd + j];
                  birthdaysOnDay[bday] = birthdaysOnDay[bday] + 1;
                  if(birthdaysOnDay[bday] == numSameBDay) {
                    peopleNeededInIteration[i] = j+1;
                    break;
                  }
                }
              }

              return(Rcpp::mean(peopleNeededInIteration));
            } ')



