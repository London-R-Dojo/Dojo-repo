library(ggmap)
library(leaflet)
library(httr)
library(dplyr)

#function to create set of circles to test travel times
create_points <- function(geo_start){
  
  #insert functionality that creates bunch of long-lats to test that
  #produces dataframe called points with this structure:
  # long | lat | direction
  # ----------------------
  #      |     |
  #      |     |
  #      |     |
  #      |     |
  return(points)
}

#function to work out travel time for series of provided points
get_distances <- function(geo_start, points){

  start <- paste(geo_start[1,2], ",", geo_start[1,1], sep = '')
  distances_df <- data.frame()
  
  #loop rows in points table  
  for (i in 1:nrow(points)){
    
    #set end variable based on value in points table for that loop
    end <- paste(points[i,2], ",", points[i,1], sep = '') 
    
    #query google api  
    url <- paste('https://maps.googleapis.com/maps/api/distancematrix/json?origins=', start, '&destinations=', end, '&mode=transit&key=API_KEY_GOES_HERE', sep="")
    data <- GET(url)
    #extract travel time in seconds - this could be done in a much nicer way!!!
    b <- content(data)$rows
    v <- data.frame(unlist(b))
    time <- as.numeric(as.character(v[4,1])) / 60 
    
    this_row <- this_row = cbind(points[i,], time)
    distances_df <- rbind(distances_df, this_row)}
  
  return(distances_df)}
  
#function to pick distance for each direction  
choose_points <- function(distances_df, time_limit){
  
  #filter out any values under time limit
  distances_df <- distances_df %>% filter(time >= time_limit)
  
  #create table of minimum time per direction and use that to filter just on those records
  direction_minimums <- distances_df %>% group_by(direction) %>% summarise(time = min(time))
  plot_points <- inner_join(distances_df, direction_minimums)
  
  return(plot_points)}

#function to plot map
plot_map <- function(geo_start, plot_points){
  
  #create map centred at input address
  m <- leaflet(geo_start) %>% 
    addProviderTiles("CartoDB.Positron") %>% 
    addCircleMarkers(stroke = TRUE, fillOpacity = 1, radius = 5, color = 'blue') %>% 
    #addPolygons(########add code here that turns points into 2 column matrix for plotting#######)
    setView(lng = geo_start[1,1], lat = geo_start[1,2], zoom = 13)
  m  # Print the map
  }

#---------Use functions above to turn User input into Output-----------
#use ggmap to turn provided address into a lat-long
geo_start <- readline("Enter Start Point: ")
time_limit <- readline("Enter Travel Time (minutes): ")

points <- create_points(geo_start)
distances_df <- get_distances(geo_start, points)
plot_points <- choose_points(distances_df, time_limit)
plot_map(geo_start, plot_points)
