
library(lubridate)

sunSetFor <- function(dd, longitude, latitude, zenith = 90, localOffset = 0) {
  calculateFor(dd, longitude, latitude, zenith, localOffset, TRUE)
}

sunRiseFor <- function(dd, longitude, latitude, zenith = 90, localOffset = 0) {
  calculateFor(dd, longitude, latitude, zenith, localOffset, FALSE)
}
	
calculateFor <- function(dd, longitude, latitude, zenith = 90, localOffset = 0, sunset = TRUE) {
  dday <- day(dd)
  dmonth <- month(dd)
  dyear <- year(dd)
  
  N <- yday(dd)
	lngHour = longitude / 15
  if(sunset) {
    t = N + ((18 - lngHour) / 24)
  } else {
    t = N + ((6 - lngHour) / 24)
  }

  M = (0.9856 * t) - 3.289
  L = (M + (1.916 * sin(toRadians(M))) + (0.020 * sin(toRadians(2 * M))) + 282.634) %% 360
  RA = (toDegrees(atan((0.91764 * tan(toRadians(L)))))) %% 360

  Lquadrant  = (floor( L/90)) * 90
	RAquadrant = (floor(RA/90)) * 90
	RA = RA + (Lquadrant - RAquadrant)
  RA = RA / 15
  sinDec = 0.39782 * sin(toRadians(L))
	cosDec = cos(asin(sinDec))
  cosH = (cos(toRadians(zenith)) - (sinDec * sin(toRadians(latitude)))) / (cosDec * cos(toRadians(latitude)))

  if(sunset) {
    H = toDegrees(acos(cosH))
  } else {
    H = 360 - toDegrees(acos(cosH))
  }

	H = H / 15
  T = H + RA - (0.06571 * t) - 6.622
  UT = (T - lngHour) %% 24
  localT = UT + localOffset

  localT
}

toRadians <- function(deg) deg*pi/180

toDegrees <- function(rad) rad*180/pi

longitude <- -0.126236
latitude <- 51.500152
dd <- today()
zenith <- 96
zenith <- 108

zenith <- 90.83
ss <- sunSetFor(dd, longitude, latitude, zenith, localOffset = 0)
ss

sr <- sunRiseFor(dd, longitude, latitude, zenith, localOffset = 0)
sr


library(data.table)
library(ggplot2)
year.data <- data.table(day = seq(ymd("2016-01-01"), ymd("2016-12-31"), by = "day"))
year.data[, sun.rise := sunRiseFor(day, longitude, latitude, zenith)]
year.data[, sun.set := sunSetFor(day, longitude, latitude, zenith)]

year.data[, sunset.diff := 60*c(NA, diff(sun.set))]
year.data[, sunrise.diff := 60*c(NA, diff(sun.rise))]

year.diff.m <- melt(year.data[, list(sunset.diff, sunrise.diff, day)], id.vars = "day", variable.name = "Type", value.name = "Time")
ggplot(year.diff.m, aes(day, Time)) + geom_line(aes(color = Type))

year.dd <- melt(year.data, id.vars = "day", variable.name = "Type", value.name = "Time")

ggplot(year.dd, aes(day, Time)) + geom_line(aes(color = Type))

library(maptools)
