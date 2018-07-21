library(shiny)
library(cyjShiny)
library(htmlwidgets)
#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  includeScript("message-handler.js"),

  tags$head(
          tags$link(rel = "stylesheet", type = "text/css",
                    href = "http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css")),
  sidebarLayout(
     sidebarPanel(
        actionButton("randomRoiButton", "Random roi"),
        hr(),
        width=2
        ),
     mainPanel(
        cyjShinyOutput('cyjShiny'),
        width=10
        )
     ) # sidebarLayout
))
#----------------------------------------------------------------------------------------------------
server = function(input, output, session) {

   observeEvent(input$randomRoiButton, {
      input$randomRoiButton
      session$sendCustomMessage(type="selectNodes", message=(list("A", "B")))
      })

  output$value <- renderPrint({ input$action })
  output$cyjShiny <- renderCyjShiny(
    cyjShiny("hello shinyApp")
    )

} # server
#----------------------------------------------------------------------------------------------------
showRegion <- function(roi)
{

} # showRegion
#----------------------------------------------------------------------------------------------------
# shinyApp(ui = ui, server = server)
