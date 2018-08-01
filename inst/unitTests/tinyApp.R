library(shiny)
library(cyjShiny)
library(htmlwidgets)

name <- "Omar"
age <- 20
height <- 67

data <- data.frame((list(name, age, height)))
#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  # includeScript("message-handler.js"),

  tags$head(
          tags$link(rel = "stylesheet", type = "text/css",
                    href = "http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css")),
  sidebarLayout(
     sidebarPanel(
        actionButton("selectNodes", "Select Nodes"),
        actionButton("loadStyleFileButton", "LOAD style.js"),
        actionButton("hideSelectedNodes", "Hide Selected Nodes"),
        actionButton("getNodes", "Get Node Names"),
        actionButton("hideAllEdges", "Change Background"),
        actionButton("sendMtx", "Send Matrix"),

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
server = function(input, output, session)
{
    observeEvent(input$selectNodes, {
        printf("about to sendCustomMessage, selectNodes")
        session$sendCustomMessage(type="selectNodes", message=list("a", "b"))
    })

    #observeEvent(input$sendMtx, {
     #   printf("about to sendCustomMessage, sendMtx")
      #  session$sendCustomMessage(type="sendMtx", data = data)
       # })

    observeEvent(input$hideSelectedNodes, { #DOESNT WORK
        printf("about sendCustomMessage, hideSelectedNodes")
        session$sendCustomMessage(type="hideSelectedNodes", message=list())
        })

    observeEvent(input$getNodes, { #DOESNT WORK
        printf("about to sendCustomMessage, getNodes")
        session$sendCustomMessage(type="getNodes", message=(list("all")))
    })

    observeEvent(input$hideAllEdges, {
        printf("about to sendCustomMessage, setBackgroundColor") #DOESNT WORK
        session$sendCustomMessage(type="setBackgroundColor", message=list("lightblue"))
        })
    
    observeEvent(input$loadStyleFileButton, { #DOESNT WORK
        printf("about to sendCustomMessage, loadStyleFile")
        session$sendCustomMessage(type="loadStyleFile", message=(list(filename="style.js")))
    })
    
    
    output$value <- renderPrint({ input$action })
    output$cyjShiny <- renderCyjShiny(
        cyjShiny(data, #data created at the top of tinyApp.R
                 "hello shinyApp")
    )
    
} # server
#----------------------------------------------------------------------------------------------------
showRegion <- function(roi)
{

} # showRegion
#----------------------------------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
