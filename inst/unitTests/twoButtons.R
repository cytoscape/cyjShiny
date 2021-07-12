
library(shiny)
library(shinyjs)
if (interactive()) {
    
    shinyApp(
        ui = fluidPage(
            useShinyjs(),  # Set up shinyjs
            "Auto Click Count:", textOutput("number", inline = TRUE), br(),
            actionButton("btn1", "Click me"), br(),br(),
            actionButton("btn2", "Auto Click"), br(), br(),
            "The Auto Click button will be disable after click on click me,
      For Verification auto counts is printing above."
        ),
        server = function(input, output) {
            observeEvent(input$btn1, {
                onclick("btn1", {
                    click("btn2")
                    disable("btn2")
                })
            })
            output$number <- renderText({
                input$btn2
            })
            
        }
    )
}