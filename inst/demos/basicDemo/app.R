library(shiny)
library(cyjShiny)
library(htmlwidgets)
library(graph)
library(jsonlite)

# HELPER FUNCTIONS ----
# printf prints formatted output like in C
printf <- function(...) cat(sprintf(...))

# LOAD DATA ----
# The yeast galactose network was the earliest demo used in the Cytoscape project,
# consisting of the graph (a Bioconductor graphNEL) and expression (a data.frame)

g <- get(load(system.file(package="cyjShiny", "extdata", "yeastGalactoseGraphNEL.RData")))
printf("--- loaded g")
print(g)
tbl.mrna <- get(load(system.file(package="cyjShiny", "extdata", "yeastGalactoseExpressionTable.RData")))
printf("--- loaded tbl.mrna: %d x %d", nrow(tbl.mrna), ncol(tbl.mrna))

# GENERATE GRAPH ----
tbl.mrna <- as.data.frame(tbl.mrna)
nodeAttrs <- nodeData(g, attr="label")

# Not used in all three experimental conditions
g <- removeNode("YER056CA", g) 

yeastGalactoseNodeNames <- as.character(nodeAttrs)
yeastGalactodeNodeIDs <- nodes(g)

g <- addNode("gal1RGexp", g)

## Convert graphNEL data to cytoscape.js JSON structure (see https://js.cytoscape.org/#notation/elements-json)
# NOTE: graphNEL is not a requirement of cyjShiny, but the cytoscape.js JSON structured string in variable "graph" is
graph <- graphNELtoJSON(g)

# Style files (see https://js.cytoscape.org/#style)
yeastGalactoseStyleFile <- system.file(file.path("demos", "basicDemo", "yeastGalactoseStyle.js"), package="cyjShiny")
basicStyleFile <- system.file(file.path("demos", "basicDemo", "basicStyle.js"), package="cyjShiny")

# SET INPUT OPTIONS ----
styleList <- c("", "Basic"="basicStyleFile", "Yeast-Galactose"="yeastGalactoseStyleFile")
condition <- c("gal1RGexp", "gal4RGexp", "gal80Rexp")

# UI ----
ui <-  shinyUI(fluidPage(

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
                                "preset",
                                "fcose")),

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
      mainPanel(
        cyjShinyOutput('cyjShiny'),
        width=10
      )
  ) # sidebarLayout
))

# SERVER ----
server <- function(input, output, session) {
    # Event observers 
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

    observeEvent(input$loadStyleFile, ignoreInit=TRUE, {
        if(input$loadStyleFile != "") {
            styleFile = get(input$loadStyleFile)
            loadStyleFile(styleFile)  
        }
    })

    observeEvent(input$doLayout, ignoreInit=TRUE,{
        strategy <- input$doLayout
        doLayout(session, strategy)
        #session$sendCustomMessage(type="doLayout", message=list(input$doLayout))
    })

    observeEvent(input$selectName, ignoreInit=TRUE,{
        session$sendCustomMessage(type="selectNodes", message=list(input$selectName))
    })

    observeEvent(input$sfn, ignoreInit=TRUE,{
        session$sendCustomMessage(type="sfn", message=list())
    })

    observeEvent(input$fitSelected, ignoreInit=TRUE,{
        fitSelected(session, 100)
    })

    observeEvent(input$getSelectedNodes, ignoreInit=TRUE, {
        output$selectedNodesDisplay <- renderText({" "})
        getSelectedNodes(session)
    })

    observeEvent(input$clearSelection, ignoreInit=TRUE, {
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

    # Output variables 
    output$value <- renderPrint({ input$action })
    
    output$cyjShiny <- renderCyjShiny({
       cyjShiny(graph, layoutName="cose", styleFile=yeastGalactoseStyleFile)
    })
} 

# RUN SHINY APP ----
shinyApp(ui = ui, server = server)
