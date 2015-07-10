library(XML)
library(data.table)
library(ggmap)
library(sp)
library(rgdal)

source("func.R")
source("clean.R")

LongLatToUTM<-function(x,y,zone){
 xy <- data.frame(ID = 1:length(x), X = x, Y = y)
 coordinates(xy) <- c("X", "Y")
 proj4string(xy) <- CRS("+proj=longlat +datum=WGS84")  ## for example
 res <- spTransform(xy, CRS(paste("+proj=utm +zone=",zone," ellps=WGS84",sep='')))
 return(as.data.frame(res))
}

main <- function() {
  st.file <- "../data/stations-facilities.xml"
  stations <- parseStationFacilities(st.file)
  stations <- cleanZones(stations)
  stations[, c("lon","lat", "alt") := parseCoordinates(coordinates)]

  zone1.stations <- stations[zone == 1]
  london <- get_map(location = "London", zoom = 12)

  zone1.chull.p <- chull(zone1.stations$lon, zone1.stations$lat)
  zone1.chull.p <- c(zone1.chull.p, zone1.chull.p[1])
  
  zone1.chull <- zone1.stations[zone1.chull.p]


  #   ggmap(london)
  #   ggmap(london) +  geom_point(data = zone1.stations, aes(lon, lat))# + stat_density2d(data = zone1.stations, aes(x = lon, y = lat,  fill = ..level.., alpha = ..level..), size = 0.01, bins = 16, geom = 'polygon') 
  #   ggmap(london) +  geom_point(data = zone1.stations, aes(lon, lat)) 

  lat.ranges <- gridRanges(zone1.stations$lat)
  lon.ranges <- gridRanges(zone1.stations$lon)
   
  grid.points.num <- 100

  lat.points <- seq(lat.ranges[1], lat.ranges[2], length.out = grid.points.num)
  lon.points <- seq(lon.ranges[1], lon.ranges[2], length.out = grid.points.num)

  grid.points <- merge(data.table( id = 1, lat = lat.points),
                       data.table( id = 1, lon = lon.points), by = "id", allow.cartesian = TRUE)

  
  utm.grid <- LongLatToUTM(grid.points$lon, grid.points$lat, 30)
  grid.points$ID <- seq(1, nrow(grid.points))
  grid.points <- merge(grid.points, utm.grid, by = "ID")


  stations.utm.grid <- LongLatToUTM(zone1.stations$lon, zone1.stations$lat, zone = 30)

  zone1.stations$ID <- seq(1, nrow(zone1.stations))
  zone1.stations <- merge(zone1.stations, stations.utm.grid, by = "ID")

                     
                     #   grid.points$distance <- NA
  #   grid.points$name <- NA
  grid.points$id <- seq(1, nrow(grid.points))

  grid.distances <- grid.points[, calculateDistance(X, Y, zone1.stations), by = id]
  gg <- merge(grid.distances, grid.points, by = "id")

  gg.inside.zone1 <- gg[, inside.zone1 := point.in.polygon(lon, lat, zone1.chull$lon, zone1.chull$lat)]
  gg.inside.zone1 <- gg.inside.zone1[inside.zone1 == 1]

  gg.inside.zone1 <- gg.inside.zone1[order(distance, decreasing = TRUE)]

  furthest.point <- head(gg.inside.zone1, n = 1)
  ggmap(london) +  geom_point(data = zone1.stations, aes(lon, lat)) + geom_point(data = gg.inside.zone1, aes(lon, lat, color = distance), alpha = 0.6) +geom_polygon(data = zone1.chull, aes(lon, lat), alpha = 0.1) + scale_color_gradient2(low = "white", high = "red") + geom_point(data = furthest.point, aes(lon, lat), shape =4, color = "blue" , size = 5)

  further.point.rev <- revgeocode(c(furthest.point$lon, furthest.point$lat))


  ggmap(london) +  geom_point(data = zone1.stations, aes(lon, lat)) + geom_point(data = gg.inside.zone1, aes(lon, lat, color = name), alpha = 0.6) 

  ggmap(london) +  geom_point(data = zone1.stations, aes(lon, lat)) + geom_polygon(data = zone1.chull, aes(lon, lat), alpha = 0.2)

  ggmap(london) + geom_polygon(data = zone1.chull, aes(lon, lat), alpha = 0.2)
}

calculateDistance <- function(p.X, p.Y, stations) {
  ss <- stations[, data.table( distance = euclidDistance(X, p.X, Y, p.Y), name = name) , by = id]
  min.dist <- ss[ distance == min(distance)][, list(name, distance)]
}

euclidDistance <- function(X, p.X, Y, p.Y) {  
  sqrt( (X - p.X)^2 + (Y - p.Y)^2)/1000
}

gridRanges <- function(ll) {

  lat.max <- max(ll)
  lat.min <- min(ll)
  lat.range <- abs(lat.max - lat.min)
   buff <- 0.10

  c(lat.min - buff*lat.range, lat.max + buff*lat.range)
}
