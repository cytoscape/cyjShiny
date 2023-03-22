library(shiny)
library(cyjShiny)
library(htmlwidgets)
library(graph)
library(jsonlite)
library(later)

# PURPOSE ----
# Load and visualize networks generated in Cytoscape Desktop 

#----------------------------------------------------------------------------------------------------
demo.directory <- system.file(package="cyjShiny", "extdata", "demoGraphsAndStyles")
styles <- c("",
            "default style" = "default style",
            "simple"      = file.path(demo.directory, "smallDemoStyle.json"),
            "galFiltered" = file.path(demo.directory, "galFiltered-style.json"))

networks <- c("",
              "simple"      = file.path(demo.directory, "smallDemo.cyjs"),
              "galFiltered" = file.path(demo.directory, "galFiltered.cyjs"))


#----------------------------------------------------------------------------------------------------
graph.json.filename <- "galFiltered/galFiltered.cyjs"
style.json.filename <- "galFiltered/galFiltered-style.json"

graph.json.filename <- "simple/smallDemo.cyjs"
style.json.filename <- "simple/smallDemoStyle.json"

#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  tags$style("#cyjShiny{height:95vh !important;}"),
  titlePanel(title="from cytoscape desktop"),
  sidebarLayout(
      sidebarPanel(
          selectInput("loadNetworkFile", "Select Network: ", choices=networks),
          selectInput("loadStyleFile", "Select Style: ", choices=styles),
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

          #selectInput("setNodeAttributes", "Select Condition:", choices=condition),
          #selectInput("selectName", "Select Node by ID:", choices = c("", nodes(g))),
          actionButton("sfn", "Select First Neighbor"),
          actionButton("fit", "Fit Graph"),
          actionButton("fitSelected", "Fit Selected"),
          actionButton("clearSelection", "Clear Selection"), HTML("<br>"),
          actionButton("loopConditions", "Loop Conditions"), HTML("<br>"),
          actionButton("removeGraphButton", "Remove Graph"), HTML("<br>"),
          actionButton("addRandomGraphFromDataFramesButton", "Add Random Graph"), HTML("<br>"),
          actionButton("getSelectedNodes", "Get Selected Nodes"), HTML("<br><br>"),
          htmlOutput("selectedNodesDisplay"),
          width=2
      ),
     mainPanel(cyjShinyOutput('cyjShiny'), width=10),
     fluid=FALSE
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

    observeEvent(input$loadNetworkFile,  ignoreInit=TRUE, {
       filename <- input$loadNetworkFile
       if(filename != ""){
          tryCatch({
             loadNetworkFromJSONFile(filename)
             }, error=function(e) {
                msg <- sprintf("ERROR in network file '%s': %s", input$loadNetworkFile, e$message)
                showNotification(msg, duration=NULL, type="error")
                })
           later(function() {updateSelectInput(session, "loadNetworkFile", selected=character(0))}, 0.5)
          }
       })

    observeEvent(input$loadStyleFile,  ignoreInit=TRUE, {
       if(input$loadStyleFile != ""){
          tryCatch({
             loadStyleFile(input$loadStyleFile)
             }, error=function(e) {
                msg <- sprintf("ERROR in stylesheet file '%s': %s", input$loadStyleFile, e$message)
                showNotification(msg, duration=NULL, type="error")
                })
           later(function() {updateSelectInput(session, "loadStyleFile", selected=character(0))}, 0.5)
          }
       })

    observeEvent(input$doLayout,  ignoreInit=TRUE,{
       if(input$doLayout != ""){
          strategy <- input$doLayout
          doLayout(session, strategy)
          later(function() {updateSelectInput(session, "doLayout", selected=character(0))}, 1)
          }
       })

    observeEvent(input$selectName,  ignoreInit=TRUE,{
       selectNodes(session, input$selectName)
       })

    observeEvent(input$sfn,  ignoreInit=TRUE,{
       selectFirstNeighbors(session)
       })

    observeEvent(input$fitSelected,  ignoreInit=TRUE,{
       fitSelected(session, 100)
       })

    observeEvent(input$getSelectedNodes, ignoreInit=TRUE, {
       output$selectedNodesDisplay <- renderText({" "})
       getSelectedNodes(session)
       })

    observeEvent(input$clearSelection,  ignoreInit=TRUE, {
       clearSelection(session)
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

    observeEvent(input$removeGraphButton, ignoreInit=TRUE, {
        removeGraph(session)
        })

    observeEvent(input$addRandomGraphFromDataFramesButton, ignoreInit=TRUE, {
        source.nodes <-  LETTERS[sample(1:5, 5)]
        target.nodes <-  LETTERS[sample(1:5, 5)]
        tbl.edges <- data.frame(source=source.nodes,
                                target=target.nodes,
                                interaction=rep("generic", length(source.nodes)),
                                stringsAsFactors=FALSE)
        all.nodes <- sort(unique(c(source.nodes, target.nodes, "orphan")))
        tbl.nodes <- data.frame(id=all.nodes,
                                type=rep("unspecified", length(all.nodes)),
                                stringsAsFactors=FALSE)
        print(tbl.nodes)
        print(tbl.edges)
        addGraphFromDataFrame(session, tbl.edges, tbl.nodes)
        })

    observeEvent(input$selectedNodes, {
        newNodes <- input$selectedNodes;
        output$selectedNodesDisplay <- renderText({
           paste(newNodes)
           })
        })

    output$value <- renderPrint({ input$action })
    output$cyjShiny <- renderCyjShiny({
       graphAsJSON <- readAndStandardizeJSONNetworkFile(graph.json.filename)
       cyjShiny(graph=graphAsJSON, layoutName="preset", styleFile=style.json.filename)
       })

} # server
#----------------------------------------------------------------------------------------------------
runApp(shinyApp(ui = ui, server = server))
