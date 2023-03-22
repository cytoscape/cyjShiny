library(cyjShiny)
library(DT)
library(later)

# PURPOSE ----
# Within a session, save node positions and restore positions for nodes moved after positions saved

printf <- function(...) cat(sprintf(...))

#----------------------------------------------------------------------------------------------------
styles <- c("",
            "generic style"="basicStyle.js",
            "style 01" = "style01.js")
#----------------------------------------------------------------------------------------------------
# create  data.frames for nodes, edges, and two simulated experimental variables, in 3 conditions
#----------------------------------------------------------------------------------------------------
state <- new.env(parent=emptyenv())
state$tbl.nodePositions <- data.frame()
#----------------------------------------------------------------------------------------------------
tbl.nodes <- data.frame(id=c("A", "B", "C"),
                        type=c("kinase", "TF", "glycoprotein"),
                        lfc=c(1, 1, 1),
                        count=c(0, 0, 0),
                        stringsAsFactors=FALSE)

tbl.edges <- data.frame(source=c("A", "B", "C"),
                        target=c("B", "C", "A"),
                        interaction=c("phosphorylates", "synthetic lethal", "unknown"),
                        stringsAsFactors=FALSE)

graph.json <- dataFramesToJSON(tbl.edges, tbl.nodes)

tbl.lfc <- data.frame(A=c(0,  1,   1,  -3),
                      B=c(0,  3,   2,   3),
                      C=c(0, -3,  -2,  -1),
                      stringsAsFactors=FALSE)

rownames(tbl.lfc) <- c("baseline", "cond1", "cond2", "cond3")

tbl.count <- data.frame(A=c(1, 10,  100, 150),
                        B=c(1, 5,   80,  3),
                        C=c(1, 100, 50,  300),
                        stringsAsFactors=FALSE)

rownames(tbl.count) <- c("baseline", "cond1", "cond2", "cond3")

#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

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
                                "preset",
                                "fcose")),

          selectInput("showCondition", "Select Condition:", choices=rownames(tbl.lfc)),
          selectInput("selectName", "Select Node by ID:", choices = c("", sort(tbl.nodes$id))),
          actionButton("sfn", "Select First Neighbor"),
          actionButton("fit", "Fit Graph"),
          actionButton("fitSelected", "Fit Selected"),
          actionButton("clearSelection", "Clear Selection"), HTML("<br>"),
          #actionButton("loopConditions", "Loop Conditions"), HTML("<br>"),
          actionButton("removeGraphButton", "Remove Graph"), HTML("<br>"),
          actionButton("addRandomGraphFromDataFramesButton", "Add Random Graph"), HTML("<br>"),
          actionButton("getSelectedNodes", "Get Selected Nodes"), HTML("<br><br>"),
          actionButton("saveLayout", "Save Layout"),
          actionButton("restoreLayout", "Restore Layout"), HTML("<br><br>"),
          htmlOutput("selectedNodesDisplay"),
          width=3
      ),
     mainPanel(fluidRow(
        cyjShinyOutput('cyjShiny', width="800px", height="800px")
        ),
        width=9)
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
       #printf(" condition.name: %s", condition.name)
       values <- as.numeric(tbl.lfc[condition.name,])
       node.names <- colnames(tbl.lfc)
       #printf("sending lfc values for %s: %s", paste(node.names, collapse=", "), paste(values, collapse=", "))
       setNodeAttributes(session, attributeName="lfc", nodes=node.names, values)
       values <- as.numeric(tbl.count[condition.name,])
       node.names <- colnames(tbl.count)
       #printf("sending count values for %s: %s", paste(node.names, collapse=", "), paste(values, collapse=", "))
       setNodeAttributes(session, attributeName="count", nodes=colnames(tbl.count), values)
       })

    observeEvent(input$loadStyleFile,  ignoreInit=TRUE, {
       if(input$loadStyleFile != ""){
          filename <- input$loadStyleFile
          if(!file.exists(filename)){
             msg <- sprintf("%s style file not found", filename)
             showModal(modalDialog(title="Style file error", msg))
          } else {
          tryCatch({
             loadStyleFile()
             }, error=function(e) {
                msg <- sprintf("ERROR in stylesheet file '%s': %s", input$loadStyleFile, e$message)
                showNotification(msg, duration=NULL, type="error")
                })
           later(function() {updateSelectInput(session, "loadStyleFile", selected=character(0))}, 0.5)
          }}
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

    observeEvent(input$tbl.nodePositions, ignoreInit=TRUE, {
       printf("new posTable ready");
       tbl <- fromJSON(input$tbl.nodePositions)
       state$tbl.nodePositions <- tbl
       print(tbl)
       })

    observeEvent(input$saveLayout, ignoreInit=TRUE, {
       getNodePositions(session)
       })

    observeEvent(input$restoreLayout, ignoreInit=TRUE, {
       tbl.pos <- state$tbl.nodePositions
       if(nrow(tbl.pos) > 0)
          setNodePositions(session, tbl.pos)
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
          #  communicated here via assignement in cyjShiny.js
          #     Shiny.setInputValue("selectedNodes", value, {priority: "event"});
        newNodes <- input$selectedNodes;
        output$selectedNodesDisplay <- renderText({
           paste(newNodes)
           })
        })

    output$value <- renderPrint({ input$action })

    output$cyjShiny <- renderCyjShiny({
       cyjShiny(graph=graph.json, layoutName="cola", height=800)
       })


} # server
#----------------------------------------------------------------------------------------------------
app <- shinyApp(ui = ui, server = server)
