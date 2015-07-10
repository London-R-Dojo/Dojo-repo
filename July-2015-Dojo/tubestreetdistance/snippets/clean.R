
cleanZones <- function(stations) {
  stations[, zone := parseFirstDigit(zone)]
  stations[ name %in% c("King's Cross St. Pancras", 
                        "St. James's Park",
                        "St. Paul's")]$zone = 1
  stations
}

parseFirstDigit <- function(zone) {
  as.numeric(gsub("(\\d)[+a-d].*", "\\1", zone, perl = TRUE))
}
