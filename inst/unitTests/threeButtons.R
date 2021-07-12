library(shiny)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),
  actionButton("button", "Click me"),
  div(id = "hello", "Hello!")
)

server <- function(input, output) {
  observeEvent(input$button, {
    toggle("hello")
  })
}

shinyApp(ui, server)