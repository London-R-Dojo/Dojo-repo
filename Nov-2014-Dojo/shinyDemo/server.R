# Define server logic required to draw a histogram
library(ggplot2)
library(ggthemes)
library(shiny)
data(mtcars)
shinyServer(function(input, output) {
  
  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should re-execute automatically
  #     when inputs change
  #  2) Its output type is a plot
  
  output$distPlot <- renderPlot({
    
    # draw the histogram with the specified number of bins
    # Histogram overlaid with kernel density curve
    ggplot(mtcars[mtcars$wt>=input$wt[1]&mtcars$wt<=input$wt[2],], aes(x=wt)) + 
      geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                     binwidth=input$bin,
                     colour="black", fill="white") +
      geom_density(alpha=.2, fill="#FF6666", adjust=input$density) + theme_tufte()
  })
})

