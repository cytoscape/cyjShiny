library(shiny)


ui <- fluidPage(
        
        actionButton(inputId = "Print_Hello", label = "Print_Hello World"),
        
        textOutput("Server_Hello")
        
    )

server <- function(input, output, session) {
    
    observeEvent(input$Print_Hello,{
        
        output$Server_Hello = renderText("Hello world")
    })
    
    
}
# Run the application 
shinyApp(ui = ui, server = server)