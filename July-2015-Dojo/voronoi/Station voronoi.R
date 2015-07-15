#####################################################################################
################## London furthest point from the subway ############################
#####################################################################################

  # libraries
library(data.table)
library(deldir)
library(ggmap) # install.packages("ggmap")

  # First, get the data:
coord.station <- fread("tfl.stations.csv")

  # only zones 1 and 2:
coord.station.min <- coord.station[zone %in% c(1, 2), ]

  # plot zones 1 and 2:
zones.london <- ggplot() +
          geom_point(data = coord.station.min, aes(x = lon, y = lat, colour = as.factor(zone))) + scale_colour_discrete(name = "Zone")
zones.london

  # voronoi
voronoi <- deldir(coord.station.min$lat, coord.station.min$lon)

head(voronoi$dirsgs)
head(voronoi$delsgs)
head(voronoi$rw)

   # plot the voronoi diagram:
zones.london.vor <- ggplot() +
  geom_segment(data = voronoi$dirsgs, aes(x = y1, y = x1, xend = y2, yend = x2)) +
  geom_point(data = coord.station.min, aes(x = lon, y = lat, colour = as.factor(zone))) +
  scale_colour_discrete(name = "Zone")
zones.london.vor


### Finding the furthest point:
    #first, the set of unique polygon summit:
coords.poly.center2 <- voronoi$dirsgs[voronoi$dirsgs[, 1] < 51.56 & voronoi$dirsgs[, 1] > 51.46 &
                                        voronoi$dirsgs[, 2] < -0.07 & voronoi$dirsgs[, 2] > -0.20, ]
coords.poly.center3 <- unique(coords.poly.center2[, c("x1", "y1")])


  # secondly, plotting them:
zones.london.vor.summit <- ggplot() +
  geom_segment(data = voronoi$dirsgs, aes(x = y1, y = x1, xend = y2, yend = x2)) +
  geom_point(data = coord.station.min, aes(x = lon, y = lat, colour = as.factor(zone)), size = 3) +
  scale_colour_discrete(name = "Zone") +
  geom_point(data = coords.poly.center3, aes(x = y1, y = x1), color = "blue", size = 3)
zones.london.vor.summit

  # finding the furthest point
lowest.coord <- merge(coords.poly.center3, coord.station.min[, list(lat, lon)], all.x = T)
                      
lowest.coord.dt <- data.table(lowest.coord)

  # distance:
lowest.coord.dt[, dist := sqrt((lon-y1)^2+(lat-x1)^2)]


  ### keeping only the closest distance:
lowest.coord.dt[, min := min(dist), by = list(x1, y1)]

min <- lowest.coord.dt[dist == min, ]

min[, min.coord := max(dist)]
min.coordinates <-  min[min.coord ==dist, ]

# Thirdly, plotting the point:
zones.london.point <- ggplot() +
  geom_segment(data = voronoi$dirsgs, aes(x = y1, y = x1, xend = y2, yend = x2)) +
  geom_point(data = coord.station.min, aes(x = lon, y = lat, colour = as.factor(zone)), size = 3) +
  scale_colour_discrete(name = "Zone") +
  geom_point(data = coords.poly.center3, aes(x = y1, y = x1), color = "blue", size = 3)+
  geom_point(data = min.coordinates, aes(x = y1, y = x1), color = "green", size = 4)
zones.london.point

##### seems logic, but not exactly the good one





