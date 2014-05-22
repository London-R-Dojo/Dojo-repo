
# Define UI for random distribution application 
shinyUI(fluidPage(
   
   # Application title
   headerPanel("Tabsets"),
   
   # Sidebar with controls to select the random distribution type
   # and number of observations to generate. Note the use of the br()
   # element to introduce extra vertical spacing
   sidebarPanel(position = 'right',
      radioButtons("dist", "Distribution type:",
                   list("Normal" = "norm",
                        "Uniform" = "unif",
                        "Log-normal" = "lnorm",
                        "Exponential" = "exp"),
                   selected = 'exp'),
      
      br(),
      
      sliderInput("n", 
                  "Number of observations:", 
                  value = 500,
                  min = 1, 
                  max = 1000),
      
      br(),
      
      sliderInput("angle", 
                  "Angle:", 
                  value = 0,
                  min = -180, 
                  max = 180)
   ),

# Show a tabset that includes a plot, summary, and table view
# of the generated distribution
mainPanel(
   tabsetPanel(
      tabPanel("Plot", plotOutput("plot")),
      tabPanel("map", plotOutput("map")),
      tabPanel("Summary", verbatimTextOutput("summary")), 
      tabPanel("Table", tableOutput("table")),
      tabPanel('testtab', plotOutput('testplot')),
      tabPanel('gvisPanel', htmlOutput("gvis"))
   )
))
)
