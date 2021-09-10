# test_3node3edgeNetwork.R
# this small app provides the simplest test of the cyjShiny widget:
#  - create a 3-node 3-edge network from a data.frame
#  - display it without styling in the browser
#  - use the shinytest framework to establish that the network was rendered
#  - exercise the query methods in the api
#  - print progress and ultimate success or failure messages to the console
#  - runs without interactivity from the shell
#----------------------------------------------------------------------------------------------------
# create  data.frames for nodes, edges, and two simulated experimental variables, in 3 conditions
#----------------------------------------------------------------------------------------------------
library(cyjShiny)
library(later)
#----------------------------------------------------------------------------------------------------
tbl.nodes <- data.frame(id=c("X", "Y", "Z"),
                        type=c("kinase", "TF", "glycoprotein"),
                        x=c(50, 180, 600),
                        y=c(150, 90, 150),
                        lfc=c(1, 1, 1),
                        count=c(0, 0, 0),
                        stringsAsFactors=FALSE)

tbl.edges <- data.frame(source=c("X", "Y", "Z"),
                        target=c("Y", "Z", "X"),
                        interaction=c("phosphorylates", "synthetic lethal", "unknown"),
                        stringsAsFactors=FALSE)

graph.json <- dataFramesToJSON(tbl.edges, tbl.nodes)

#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  tags$head(tags$style("#cyjShiny{height:95vh !important;}")),
  titlePanel(title="cyjShiny automate test"),
  sidebarLayout(
    sidebarPanel(
      selectInput("doLayout", "Select Layout:",
                  choices=c("",
                            "cose",
                            "cola",
                            "circle",
                            "concentric",
                            "breadthfirst",
                            "grid",
                            "random",
                            "fcose",
                            "springy")),

      selectInput("selectName", "Select Node by ID:", choices = c("", sort(tbl.nodes$id))),
      actionButton("sfn", "Select First Neighbor"),
      actionButton("fit", "Fit Graph"),
      actionButton("fitSelected", "Fit Selected"),
      #actionButton("showAll", "showAll"),
      actionButton("addRandomGraphFromDataFramesButton", "Add Random Graph"), HTML("<br>"),
      actionButton("getSelectedNodes", "Get Selected Nodes"), HTML("<br><br>"),
      htmlOutput("selectedNodesDisplay"),
      width=3
    ),
    mainPanel(cyjShinyOutput('cyjShiny', height=400),width=9)
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

  observeEvent(input$loadStyleFile,  ignoreInit=FALSE, {
    if(input$loadStyleFile != ""){
      tryCatch({
        loadStyleFile(input$loadStyleFile)
      }, error=function(e) {
        msg <- sprintf("ERROR in stylesheet file '%s': %s", input$loadStyleFile, e$message)
        showNotification(msg, duration=NULL, type="error")
      })
      #later(function() {updateSelectInput(session, "loadStyleFile", selected=character(0))}, 0.5)
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

  #observeEvent(input$showAll,  ignoreInit=TRUE, {
   # output$showAll <- renderText({" "})
   # showAll(session)
  #})

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

  #observeEvent(input$removeGraphButton, ignoreInit=TRUE, {
   # removeGraph(session)
  #})

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
    printf("-- about to addGraphFromDataFrame")
    print(tbl.edges)
    print(tbl.nodes)
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
    cyjShiny(graph=graph.json, layoutName="preset")
  })

} # server
#----------------------------------------------------------------------------------------------------
app <- shinyApp(ui = ui, server = server)
