library(cyjShiny)
library(later)
#----------------------------------------------------------------------------------------------------
styles <- c("",
            "from Cytoscape desktop"="smallDemoStyle.json",
            "generic style"="basicStyle.js")
#----------------------------------------------------------------------------------------------------
# create  read json text for graph, two simulated experimental variables in data.frames, 3 conditions
#----------------------------------------------------------------------------------------------------
json.filename <- "smallDemo.cyjs"
graph.json <- paste(readLines(json.filename), collapse="")

#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  tags$head(
     tags$style("#cyjShiny{height:95vh !important;}")),
  sidebarLayout(
      sidebarPanel(
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
                                "dagre",
                                "cose-bilkent")),


          actionButton("sfn", "Select First Neighbor"),
          actionButton("fit", "Fit Graph"),
          actionButton("fitSelected", "Fit Selected"),
          actionButton("clearSelection", "Clear Selection"), HTML("<br>"),
          #actionButton("loopConditions", "Loop Conditions"), HTML("<br>"),
          actionButton("removeGraphButton", "Remove Graph"), HTML("<br>"),
          actionButton("addRandomGraphFromDataFramesButton", "Add Random Graph"), HTML("<br>"),
          actionButton("getSelectedNodes", "Get Selected Nodes"), HTML("<br><br>"),
          htmlOutput("selectedNodesDisplay"),
          width=3
      ),
      mainPanel(cyjShinyOutput('cyjShiny'),
          width=9
      )
  ) # sidebarLayout
))
#----------------------------------------------------------------------------------------------------
server = function(input, output, session)
{
    observeEvent(input$fit, ignoreInit=TRUE, {
       fit(session, 80)
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
        condition.names <- rownames(tbl.lfc)
        for(condition.name in condition.names[-1]){
           #browser()
           lfc.vector <- as.numeric(tbl.lfc[condition.name,])
           node.names <- rownames(tbl.lfc)
           setNodeAttributes(session, attributeName="lfc", nodes=node.names, values=lfc.vector)
           #updateSelectInput(session, "setNodeAttributes", selected=condition.name)
           Sys.sleep(1)
           } # for condition.name
        updateSelectInput(session, "setNodeAttributes", selected="baseline")
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
       cyjShiny(graph=graph.json, layoutName="cola")
       })

} # server
#----------------------------------------------------------------------------------------------------
app <- shinyApp(ui = ui, server = server)

