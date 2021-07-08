library(shiny)
library(R6)


WorldTest = R6Class("WorldTest",
    
public = list(
        
        initialize = function(){
            message(sprintf("Hello print"))
        },
        
ui = function(){       
    fluidPage(
        
        actionButton(inputId = "printHelloButton", label = "PrintHello World"),
        
        textOutput("textDisplay")
        
    )},

server = function(input, output, session) {
    
    observeEvent(input$printHelloButton,{
        
        output$textDisplay = renderText("Hello world")
    })
    
    
}
)
)

x <- WorldTest$new()
runApp(shinyApp(x$ui, x$server), port=9999, launch.browser=TRUE)