# Define UI for application that draws a histogram
library(ggplot2)
library(ggthemes)
library(shiny)
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Miles per gallon"),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("wt",
                  "Weight in the range:",
                  min = 1,
                  max = 5,
                  step = 0.1,
                  value = c(2,4)),
      sliderInput("bin",
                  "Bin width:",
                  min = .01,
                  max = 2,
                  step = 0.01,
                  value = 1),
      sliderInput("density",
                  "Bandwidth:",
                  min = .01,
                  max = 2,
                  step = 0.01,
                  value = 1)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
))