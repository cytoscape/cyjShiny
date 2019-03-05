library(shiny)
library(cyjShiny)
library(htmlwidgets)
#----------------------------------------------------------------------------------------------------
# one way to create a graph is via the Bioconductor graphNEL class.
# here we use the data.frame strategy.
#----------------------------------------------------------------------------------------------------
tbl.nodes <- data.frame(id=c("A", "B", "C"),
                        type=c("kinase", "TF", "glycoprotein"),
                        lfc=c(-3, 1, 1),
                        count=c(0, 0, 0),
                        stringsAsFactors=FALSE)

tbl.edges <- data.frame(source=c("A", "B", "C"),
                        target=c("B", "C", "A"),
                        interaction=c("phosphorylates", "synthetic lethal", "unknown"),
                        stringsAsFactors=FALSE)

graph.json <- dataFramesToJSON(tbl.edges, tbl.nodes)
#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  sidebarLayout(
     sidebarPanel(
        actionButton("selectRandomNodeButton", "Select random node"),
        hr(),
        selectInput("visualStyleSelector", "Select Visual Style",
                    choices=c("Default" = "basicStyle.js", "Biological"="biologicalStyle.js")),
        h6("Send random node 'lfc' attributes (visible only with Biological Style, mapped to color):"),
        actionButton("randomNodeAttributes", "Send"),
        width=3
        ),
     mainPanel(
        cyjShinyOutput('cyjShiny'),
        width=9
        )
     ) # sidebarLayout
))
#----------------------------------------------------------------------------------------------------
server = function(input, output, session) {

   observeEvent(input$selectRandomNodeButton, ignoreInit=TRUE, {
      clearSelection(session)
      selectNodes(session, tbl.nodes$id[sample(1:3, 1)])
      })

   observeEvent(input$visualStyleSelector, ignoreInit=TRUE, {
      newStyleFile <- input$visualStyleSelector
      printf("newStyle: %s", newStyleFile)
      loadStyleFile(newStyleFile)
      })

   observeEvent(input$randomNodeAttributes, ignoreInit=TRUE, {
      nodeNames <- tbl.nodes$id
      newValues <- runif(n=3, min=-3, max=3)
      setNodeAttributes(session, attributeName="lfc", nodes=nodeNames, newValues)
      })

  output$value <- renderPrint({ input$action })
  output$cyjShiny <- renderCyjShiny(
    cyjShiny(graph=graph.json, layoutName="cola", style_file="basicStyle.js")
    )

} # server
#----------------------------------------------------------------------------------------------------
runApp(shinyApp(ui=ui,server=server))
