library(shiny)
library(cyjShiny)
library(htmlwidgets)
#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  # includeScript("message-handler.js"),

  tags$head(
          tags$link(rel = "stylesheet", type = "text/css",
                    href = "http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css")),
  sidebarLayout(
     sidebarPanel(
        actionButton("randomRoiButton", "Select Nodes"),
        actionButton("loadStyleFileButton", "LOAD style.js"),

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
      printf("about to sendCustomMessage, selectNodes")
      session$sendCustomMessage(type="selectNodes", message=(list("a", "b")))
      })

   observeEvent(input$loadStyleFileButton, {
      printf("about to sendCustomMessage, loadStyleFile")
      session$sendCustomMessage(type="loadStyleFile", message=(list(filename="style.js")))
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
