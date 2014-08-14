library(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Check url"),
  
  # Sidebar with controls to select the variable to plot against mpg
  # and to specify whether outliers should be included
  sidebarPanel(
	sliderInput("wid_with", "Window width:", 
                min=8, max=1024, value=255),

    textInput("url", "Web page", "shape-of-code.coding-guidelines.com/2013/05/17/preferential-attachment-applied-to-frequency-of-accessing-a-variable/")
    ),
  
  # Show the caption and plot of the requested variable against mpg
  mainPanel(
    h3(textOutput("caption")),
    
    plotOutput("mpgPlot"),
    
    textOutput("formattedUrl")
  )
))
