library(shiny)
library(cyjShiny)
library(htmlwidgets)
library(graph)
library(jsonlite)
#----------------------------------------------------------------------------------------------------
# the yeast galactose network was the earliest demo used in the Cytoscape project,
# consisting of the graph (a Bioconductor graphNEL) and expression (a data.frame)
g <- get(load(system.file(package="cyjShiny", "extdata", "yeastGalactoseGraphNEL.RData")))
printf("--- loaded g")
print(g)
tbl.mrna <- get(load(system.file(package="cyjShiny", "extdata", "yeastGalactoseExpressionTable.RData")))
printf("--- loaded tbl.mrna: %d x %d", nrow(tbl.mrna), ncol(tbl.mrna))
#----------------------------------------------------------------------------------------------------
tbl.mrna <- as.data.frame(tbl.mrna)
nodeAttrs <- nodeData(g, attr="label")

g <- removeNode("YER056CA", g) #not used in all three experimental conditions

yeastGalactoseNodeNames <- as.character(nodeAttrs)
yeastGalactodeNodeIDs <- nodes(g)

g <- addNode("gal1RGexp", g)
graph <- graphNELtoJSON(g)

styleList <- c("", "Yeast-Galactose"="yeastGalactoseStyle.js")
condition <- c("", "gal1RGexp", "gal4RGexp", "gal80Rexp")
#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  tags$head(
     tags$link(rel = "stylesheet", type = "text/css",
               href = "http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css"),
     tags$style("#cyjShiny{height:95vh !important;}")),
  sidebarLayout(
      sidebarPanel(
          selectInput("loadStyleFile", "Select Style: ", choices=styleList),
          selectInput("doLayout", "Select Layout:",
                      choices=c("",
                                "cose",
                                "cola",
                                "circle",
                                "concentric",
                                "breadthfirst",
                                "grid",
                                "random",
                                "dagre",
                                "cose-bilkent")),

          selectInput("setNodeAttributes", "Select Condition:", choices=condition),
          selectInput("selectName", "Select Node by ID:", choices = c("", nodes(g))),
          actionButton("sfn", "Select First Neighbor"),
          actionButton("fit", "Fit Graph"),
          actionButton("fitSelected", "Fit Selected"),
          actionButton("clearSelection", "Unselect Nodes"),
          HTML("<br>"),
          actionButton("loopConditions", "Loop Conditions"),
          HTML("<br>"),
          actionButton("getSelectedNodes", "Get Selected Nodes"),
          HTML("<br><br>"),
          htmlOutput("selectedNodesDisplay"),
          width=2
      ),
      mainPanel(cyjShinyOutput('cyjShiny'),
          width=10
      )
  ) # sidebarLayout
))
#----------------------------------------------------------------------------------------------------
server = function(input, output, session)
{
    observeEvent(input$fit, ignoreInit=TRUE, {
       fit(session, 80)
       })

    observeEvent(input$setNodeAttributes, ignoreInit=TRUE, {
       attribute <- "lfc"
       expression.vector <- switch(input$setNodeAttributes,
                                   "gal1RGexp" = tbl.mrna$gal1RGexp,
                                   "gal4RGexp" = tbl.mrna$gal4RGexp,
                                   "gal80Rexp" = tbl.mrna$gal80Rexp)
       setNodeAttributes(session, attributeName=attribute, nodes=yeastGalactodeNodeIDs, values=expression.vector)
       })

    observeEvent(input$loadStyleFile,  ignoreInit=TRUE, {
        if(input$loadStyleFile != "")
            loadStyleFile(input$loadStyleFile)
    })

    observeEvent(input$doLayout,  ignoreInit=TRUE,{
        strategy <- input$doLayout
        doLayout(session, strategy)
        #session$sendCustomMessage(type="doLayout", message=list(input$doLayout))
    })

    observeEvent(input$selectName,  ignoreInit=TRUE,{
        session$sendCustomMessage(type="selectNodes", message=list(input$selectName))
    })

    observeEvent(input$sfn,  ignoreInit=TRUE,{
        session$sendCustomMessage(type="sfn", message=list())
    })

    observeEvent(input$fitSelected,  ignoreInit=TRUE,{
        fitSelected(session, 100)
    })

    observeEvent(input$getSelectedNodes, ignoreInit=TRUE, {
        output$selectedNodesDisplay <- renderText({" "})
        getSelectedNodes(session)
    })

    observeEvent(input$clearSelection,  ignoreInit=TRUE, {
        session$sendCustomMessage(type="clearSelection", message=list())
    })

    observeEvent(input$loopConditions, ignoreInit=TRUE, {
        condition.names <- c("gal1RGexp", "gal4RGexp", "gal80Rexp")
        for(condition.name in condition.names){
           expression.vector <- tbl.mrna[, condition.name]
           setNodeAttributes(session, attributeName="lfc", nodes=yeastGalactodeNodeIDs, values=expression.vector)
           Sys.sleep(1)
           } # for condition.name
        updateSelectInput(session, "setNodeAttributes", selected="gal1RGexp")
        })

    observeEvent(input$selectedNodes, {
        newNodes <- input$selectedNodes;
        output$selectedNodesDisplay <- renderText({
           paste(newNodes)
           })
        })

    output$value <- renderPrint({ input$action })
    output$cyjShiny <- renderCyjShiny({
       styleFile <- system.file(package="cyjShiny", "extdata", "yeastGalactoseStyle.js")
       cyjShiny(graph, layoutName="cose", styleFile=styleFile)
       })

} # server
#----------------------------------------------------------------------------------------------------
runApp(shinyApp(ui = ui, server = server)) # , port=191919)
