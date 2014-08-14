######################################################
# Call Libraries (install if necessary..)
# install.packages(dplyr)
library(dplyr) # dplyr: a grammar of data manipulation
# install.packages(rCharts)
library(rCharts) # rCharts: Interactive Charts using Javascript Visualization Libraries
# install.packages(data.table)
library(data.table) # data.table: Extension of data.frame, fast with very large data sets
# install.packages(reshape2)
library(reshape2) # reshape2: Flexibly reshape data: a reboot of the reshape package.
# Set the Working Directory
setwd("C:/Users/dd420709/Desktop/")
######################################################

######################################################
######### rCharts Site
# Examples from Site
## Example 1 Facetted Scatterplot
names(iris) = gsub("\\.", "", names(iris))
rPlot(SepalLength ~ SepalWidth | Species, data = iris, color = 'Species', type = 'point')

## Example 2 Facetted Barplot
hair_eye = as.data.frame(HairEyeColor)
rPlot(Freq ~ Hair | Eye, color = 'Eye', data = hair_eye, type = 'bar')

# Example 3
r1 <- rPlot(mpg ~ wt | am + vs, data = mtcars, type = "point", color = "gear")
r1$print("chart1")

# Example 4
hair_eye_male <- subset(as.data.frame(HairEyeColor), Sex == "Male")
n1 <- nPlot(Freq ~ Hair, group = "Eye", data = hair_eye_male, type = "multiBarChart")
n1$print("chart3")
######################################################


######################################################
# Created during the R Dojo Session
# Initial Attempt to create something :P
##### Import Data
# Import Data from the Web
uk <- read.csv("http://trelford.com/UKGDP2Power.csv")
uk <- data.table(uk)
# Calling the rPlot Function
r1 <- rPlot(GDP ~ Year, uk, type='line')
# Show Output
r1
# Melt the Dataset, here I was trying to add two variable on One Graph
uk2 <- melt(uk, id="Year")
# Create another plot
r2 <- mPlot(x = "Year", y = c("GDP", "Power"), type = "Line", data = uk)
# Show Output
r2
######################################################

######################################################
# Second Attempt to show a plot with grouped data
# Import Data from the Web
world <- read.csv("http://trelford.com/GDP2Power.csv")
# Subset the data using the dplyr package
world2000 <- filter(world, Year=="2000")
# Create Plot using the Subset of World Data
d1 <- dPlot(
  GDP ~ Power, # define the graph 
  groups = c("Year","Country"), # adding factors onto the labels
  data = world2000, # the data.frame with data in
  type = "bubble", # type of chart
  height=800, # height overrides the height of the frame set by dplot
  width=1000, # width overrides the width of the frame set by dplot
  bounds = list(x=60, y=25, width=400, height=350) # adding further specification to the chart output
)
# Redefine the axis
d1$xAxis( type = "addMeasureAxis" )
d1$yAxis( type = "addMeasureAxis" )
# Add Legend to the Plot
d1$legend(
  x = 465,
  y = 0,
  width = 50,
  height = 300,
  horizontalAlign = "left"
)
# Show Output
d1
######################################################

######################################################
# Other Useful Sites to Visit from the dojo
# www.clear-lines.com/blog
# rmaps - package used for creating geographical charts
######################################################
