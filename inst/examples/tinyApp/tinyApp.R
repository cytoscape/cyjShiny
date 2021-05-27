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

graph.json <- toJSON(dataFramesToJSON(tbl.edges, tbl.nodes), auto_unbox=TRUE)
#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  tags$head(
     tags$style("#cyjShiny{height:95vh !important;}"),
     tags$style(".well{border-width:0px;}")
     ),
  sidebarLayout(
     sidebarPanel(
        actionButton("selectRandomNodeButton", "Select random node"),
        actionButton("selectTwoRandomNodesButton", "Select two random nodes"),
        hr(),
        selectInput("visualStyleSelector", "Select Visual Style",
                    choices=c("Default" = "basicStyle.js", "Biological"="biologicalStyle.js")),
        h6("Send random node 'lfc' attributes (visible only with Biological Style, mapped to color):"),
        actionButton("randomNodeAttributes", "Send"),
        h6("Try out png-saving capability, using the currently displayed network"),
        actionButton("savePNGbutton", "Save PNG to 'foo.png'"),
        width=3
        #style="margin-right:10px; padding-right:0px;"
        ),
     mainPanel(
        cyjShinyOutput('cyjShiny'),
        width=9
        #style="margin-left:0px; padding-left:0px;"
        )
     ) # sidebarLayout
))
#----------------------------------------------------------------------------------------------------
server = function(input, output, session) {

   observeEvent(input$selectRandomNodeButton, ignoreInit=TRUE, {
      clearSelection(session)
      Sys.sleep(0.5)
      selectNodes(session, tbl.nodes$id[sample(1:3, 1)])
      })

   observeEvent(input$selectTwoRandomNodesButton, ignoreInit=TRUE, {
      clearSelection(session)
      Sys.sleep(0.5)
      selectNodes(session, tbl.nodes$id[sample(1:3, 2)])
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
   output$cyjShiny <- renderCyjShiny({
     print("renderCyjShiny")
     print(graph.json)
     print(class(graph.json))
     cyjShiny(graph=graph.json, layoutName="cola")
     })

   observeEvent(input$savePNGbutton, ignoreInit=TRUE, {
     file.name <- tempfile(fileext=".png")
     savePNGtoFile(session, file.name)
     })

   observeEvent(input$pngData, ignoreInit=TRUE, {
     print("received pngData")
     png.parsed <- fromJSON(input$pngData)
     substr(png.parsed, 1, 30) # [1] "data:image/png;base64,iVBORw0K"
     nchar(png.parsed)  # [1] 768714
     png.parsed.headless <- substr(png.parsed, 23, nchar(png.parsed))  # chop off the uri header
     png.parsed.binary <- base64decode(png.parsed.headless)
     print("writing png to foo.png")
     conn <- file("foo.png", "wb")
     writeBin(png.parsed.binary, conn)
     close(conn)

     })


} # server
#----------------------------------------------------------------------------------------------------
browseURL("http://localhost:6789")
runApp(shinyApp(ui=ui,server=server), port=6789)
