library(shiny)
library(rworldmap)
library(scatterplot3d)
library(googleVis)

# Define server logic for random distribution application
shinyServer(function(input, output) {
   
   # Reactive expression to generate the requested distribution. This is 
   # called whenever the inputs change. The renderers defined 
   # below then all use the value computed from this expression
   data <- reactive({  
      dist <- switch(input$dist,
                     norm = rnorm,
                     unif = runif,
                     lnorm = rlnorm,
                     exp = rexp,
                     rnorm)
      
      data.frame(x=dist(input$n))
   })
   
   # Generate a plot of the data. Also uses the inputs to build the 
   # plot label. Note that the dependencies on both the inputs and
   # the 'data' reactive expression are both tracked, and all expressions 
   # are called in the sequence implied by the dependency graph
   output$plot <- renderPlot({
      dist <- input$dist
      n <- input$n
      hist(data()$x, 
           main=paste('r', dist, '(', n, ')', sep=''))
   })
   
   output$testplot <- renderPlot({
      cc <- colors()
      crgb <- t(col2rgb(cc))
      #       par(xpd = TRUE)
      # Sys.sleep(time=30)
      rr <- scatterplot3d(crgb, color = cc, box = FALSE, angle = input$angle,
                          xlim = c(-50, 300), ylim = c(-50, 300), zlim = c(-50, 300))
   })
   
   output$gvis <- renderGvis({
   
      gvisScatterChart(cars)
      
   })
   
   output$map  <- renderPlot({
      data = getMap()
      plot(data)
      points(runif(5) * 360 - 180,
             rep(0, 5),
             col = 'red')
   })
   
   # Generate a summary of the data
   output$summary <- renderPrint({
      summary(data())
   })
   
   # Generate an HTML table view of the data
   output$table <- renderTable({
      data()
   })
})
