library(shiny)
library(R6)
library(later)
HelloWorldDemo = R6Class("HelloWorldDemo",

  public = list( testResult=NULL,
        initialize = function(){
            message(sprintf("initializing HelloWorldDemo"))
        },

   ui = function(){
      fluidPage(
        actionButton(inputId="sayHelloButton", label="Say Hello"),
        textOutput("textDisplay")
        )},

  server = function(input, output, session) {

     helloTest <- function(){
       later(function(){
        public$testResult <- FALSE  # be pessimistic
                message(sprintf("--- executing helloTest's later function"))
                public$testResult <-checkEquals(public$textDisplay)
                message(sprintf("test result: %s", public$testResult))
                output$textDisplay <- renderText({public$testResult});
       }, 1)
     }
    observeEvent(input$sayHelloButton,{
       output$textDisplay = renderText("Hello world!")
       })
    
    if(!interactive()){
      helloTest()
        stopifnot(public$testResult == TRUE)
        quit()
        
    }  #interactive
    } # server
  ) # public
) # class

x <- HelloWorldDemo$new()
runApp(shinyApp(x$ui, x$server), port=9999, launch.browser=TRUE)
