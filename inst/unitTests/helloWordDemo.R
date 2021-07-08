library(shiny)
library(R6)


HelloWorldDemo = R6Class("HelloWorldDemo",

  public = list(
        initialize = function(){
            message(sprintf("initializing HelloWorldDemo"))
        },

   ui = function(){
      fluidPage(
        actionButton(inputId="sayHelloButton", label="Say Hello"),
        textOutput("textDisplay")
        )},

  server = function(input, output, session) {

    observeEvent(input$sayHelloButton,{
       output$textDisplay = renderText("Hello world!")
       })

    } # server
  ) # public
) # class

x <- HelloWorldDemo$new()
runApp(shinyApp(x$ui, x$server), port=9999, launch.browser=TRUE)
