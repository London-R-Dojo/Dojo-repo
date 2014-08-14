#
# Created at the R-dojo, 10 Dec 13

library(shiny)

window_width=256

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
  
  # Compute the forumla text in a reactive expression since it is 
  # shared by the output$caption expressions
  formulaText <- reactive({
    paste("Unique byte ratio")
  })
  
  # Return the formula text for printing as a caption
  output$caption <- renderText({
    formulaText()
  })

sliderValues <- reactive({
    # Compose data frame
    data.frame(
      Name = "width",
      Value = input$wid_width)
  })

  data=reactive({url=input$url})

  output$mpgPlot <- renderPlot({

  window_width=input$wid_with
  filename=paste0("http://", input$url)
#  filename="http://shape-of-code.coding-guidelines.com/2013/05/17/preferential-attachment-applied-to-frequency-of-accessing-a-variable/"
#  message(filename)

# To undersand what this code is about see:
# shape-of-code.coding-guidelines.com/2013/05/17/preferential-attachment-applied-to-frequency-of-accessing-a-variable/"

    t=readBin(filename, what="raw", n=1e8)
    
    # Sliding the window over every point is too much overhead
    cnt_points=seq(1, length(t)-window_width, 8)
    
    u=sapply(cnt_points, function(X) length(unique(t[X:(X+window_width)])))
    
    plot(u/window_width, type="l", xlab="File Offset", ylab="Fraction Unique", las=1)
  })

})
