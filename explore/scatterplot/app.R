library(shiny)

ui <- shinyUI(fluidPage(
  br(),
  actionButton("numb", "generate a random plot graph"),
  br(),
  br(),
  verbatimTextOutput("text"),
  plotOutput("plot"),
  plotOutput("plot2")
))

server <- shinyServer(function(input, output) {
  
  model <- eventReactive(input$numb, {
    # draw a random number and print it
    random <- sample(1:100, 1)
    print(paste0("The number is: ", random))
    
    # create a plot 
    set.seed(17)
    Plot <- plot(sample(1:10,1:10))
    
    # create a second plot
    set.seed(17)
    Plot2 <- plot(sample(1:100,5), sample(1:100,5))
    
    # return all object as a list
    list(random = random, Plot = Plot, Plot2=Plot2)
  })
  
  output$text <- renderText({
    # print the random number after accessing "model" with brackets.
    # It doesn't re-run the function.
    youget <- paste0("After using model()$random you get: ", model()$random,
                     ". Compare it")
    print(youget)
    youget
  })
  
  output$plot <- renderPlot({
    # render saved plot
    set.seed(17)
    Plot2 <- plot(sample(1:100,5), sample(1:100,5))
  })
  
  output$plot2 <-renderPlot({
    set.seed(17)
    Plot <- plot(sample(1:10,1:10))
  })

})


shinyApp(ui = ui, server = server)