library(XML)
library(data.table)
library(ggmap)
library(sp)
library(rgdal)

source("func.R")
source("clean.R")

main <- function() {
  st.file <- "../data/stations-facilities.xml"
  stations <- parseStationFacilities(st.file)
  stations <- cleanZones(stations)
  stations[, c("lon","lat", "alt") := parseCoordinates(coordinates)]

  zone1.stations <- stations[zone == 1]
  london <- get_map(location = "London", zoom = 12)

  lat.ranges <- gridRanges(zone1.stations$lat)
  lon.ranges <- gridRanges(zone1.stations$lon)
   
  grid.points.num <- 100

  lat.points <- seq(lat.ranges[1], lat.ranges[2], length.out = grid.points.num)
  lon.points <- seq(lon.ranges[1], lon.ranges[2], length.out = grid.points.num)

  grid.points <- merge(data.table( id = 1, lat = lat.points),
                       data.table( id = 1, lon = lon.points), by = "id", allow.cartesian = TRUE)

  
  grid.points$id <- seq(1, nrow(grid.points))

  grid.distances <- grid.points[, calculateDistance(lon, lat, zone1.stations), by = id]
  gg <- merge(grid.distances, grid.points, by = "id")


  ggmap(london) + geom_polygon(data = zone1.chull, aes(lon, lat), alpha = 0.2)
}

calculateDistance <- function(p.X, p.Y, stations) {
  ss <- stations[, data.table( distance = euclidDistance(lon, p.X, lat, p.Y), name = name) , by = id]
  min.dist <- ss[ distance == min(distance)][, list(name, distance)]
}

euclidDistance <- function(X, p.X, Y, p.Y) {  
  sqrt( (X - p.X)^2 + (Y - p.Y)^2)
}

gridRanges <- function(ll) {

  lat.max <- max(ll)
  lat.min <- min(ll)
  lat.range <- abs(lat.max - lat.min)
   buff <- 0.10

  c(lat.min - buff*lat.range, lat.max + buff*lat.range)
}
