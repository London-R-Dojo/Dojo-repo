#The below is an example of how Plotly can be used with R to graphically analyse data. For more information on the Plotly R API, visit: https://plot.ly/r/.

#The dataset was sourced from Open Data Bristol. It is available at: https://opendata.bristol.gov.uk/Environment/Shopping-Trolleys-Found-in-Rivers/b2rs-9trd.

install.packages('plotly')

library(plotly)

data.trolley <- read.csv('/Users/andrewburnie/Desktop/Projects/self-taught-languages/R/using_plotly_graphical_analysis/Shopping_Trolleys_Found_in_Rivers.csv')

#Need to replace above path with path to Shopping_Trolleys_Found_in_Rivers.csv on your computer.

str(data.trolley)

#Above shows structure of the data

unique(data.trolley$Year)

#Above gives nonrepetitive list of years in data

year_filter <- function(data, year){
  data[data$Year == year,]$Number.of.Trolleys
}

trolley.2005 <- year_filter(data.trolley, unique(data.trolley$Year)[1])
trolley.2007 <- year_filter(data.trolley, unique(data.trolley$Year)[2])
trolley.2008 <- year_filter(data.trolley, unique(data.trolley$Year)[3])
trolley.2009 <- year_filter(data.trolley, unique(data.trolley$Year)[4])
trolley.2010 <- year_filter(data.trolley, unique(data.trolley$Year)[5])
trolley.2011 <- year_filter(data.trolley, unique(data.trolley$Year)[6])

#Above creates vectors of the number of trolleys in each river for different years

River.2005 <- data.trolley[data.trolley$Year == 2005,]$River

#Above gives list of rivers

p <- plot_ly(
             data.trolley, 
             x = log1p(trolley.2005), 
             y = River.2005, 
             name = "2005", 
             mode = "line", 
             marker = list(color = "coral"), 
             line = list(color = "coral") ) %>%
     add_trace(
             x = log1p(trolley.2007), 
             name = "2007", 
             marker = list(color = "cadetblue"), 
             line = list(color = "cadetblue"))%>%
     add_trace(
             x = log1p(trolley.2008), 
             name = "2008", 
             marker = list(color = "blue"), 
             line = list(color = "blue"))%>%
     add_trace(
             x = log1p(trolley.2009), 
             name = "2009", 
             marker = list(color = "brown"), 
             line = list(color = "brown"))%>%
     add_trace(
             x = log1p(trolley.2010), 
             name = "2010", 
             marker = list(color = "darkgoldenrod"), 
             line = list(color = "darkgoldenrod"))%>%
     add_trace(
             x = log1p(trolley.2011), 
             name = "2011", 
             marker = list(color = "darkseagreen"), 
             line = list(color = "darkseagreen"))%>%
    layout(
             xaxis = list(title = "Trolleys in River"),
             yaxis = list(title = ""),
             margin = list(l = 65)
  )


p
  
  
  
  
 


