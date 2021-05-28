library(cyjShiny)
library(later)
#----------------------------------------------------------------------------------------------------
styles <- c("",
            "generic style"="basicStyle.js",
            "style 01" = "style01.js")
#----------------------------------------------------------------------------------------------------
# create  read json text for graph, two simulated experimental variables in data.frames, 3 conditions
#----------------------------------------------------------------------------------------------------
json.filename <- "simpleGraph.json"
graph.json <- paste(readLines(json.filename), collapse="")

tbl.lfc <- data.frame(A=c(0, 1,   1, -3),
                      B=c(0, 3,   2,  3),
                      C=c(0, -3, -2, -1),
                      stringsAsFactors=FALSE)

rownames(tbl.lfc) <- c("baseline", "cond1", "cond2", "cond3")

tbl.count <- data.frame(A=c(1, 10,  100, 150),
                        B=c(1, 5,   80,  3),
                        C=c(1, 100, 50,  300),
                        stringsAsFactors=FALSE)
rownames(tbl.count) <- c("baseline", "cond1", "cond2", "cond3")

tbl.interactionScores <- data.frame(sourceNode=c("A", "B", "C"),
                                    targetNode=c("B", "C", "A"),
                                    interaction=c("phosphorylates", "synthetic lethal", "unknown"),
                                    baseline=c(0, 0, 0),
                                    cond1=c(-1, 3, 10),
                                    cond2=c(10, -1, 3),
                                    cond3=c(20, 25, 30),
                                    stringsAsFactors=FALSE)

#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(
  titlePanel(title="json Graph with animations"),
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
                                "cose-bilkent",
                                "preset",
                                "euler",
                                "fcose",
                                "springy",
                                "spread")),


          selectInput("showCondition", "Select Condition:", choices=rownames(tbl.lfc)),
          selectInput("selectName", "Select Node by ID:", choices = c("", colnames(tbl.lfc))),
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

    observeEvent(input$showCondition, ignoreInit=TRUE, {
       condition.name <- isolate(input$showCondition)

       values <- as.numeric(tbl.lfc[condition.name,])
       node.names <- colnames(tbl.lfc)
       setNodeAttributes(session, attributeName="lfc", nodes=node.names, values)
       values <- as.numeric(tbl.count[condition.name,])
       node.names <- colnames(tbl.count)
       setNodeAttributes(session, attributeName="count", nodes=colnames(tbl.count), values)

       setEdgeAttributes(session,
                         attributeName="score",
                         sourceNodes=tbl.interactionScores$sourceNode,
                         targetNodes=tbl.interactionScores$targetNode,
                         interactions=tbl.interactionScores$interaction,
                         values=tbl.interactionScores[, condition.name])
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
