library(shiny)
library(cyjShiny)
library(htmlwidgets)
library(graph)
library(jsonlite)

load("yeastGalactoseGraphNEL.RData")
load("yeastGalactose.RData")
tbl.mrna <- as.data.frame(tbl.mrna)
nodeAttrs <- nodeData(g, attr="label")

g <- removeNode("YER056CA", g) #not used in all three experimental conditions

yeastGalactoseNodeNames <- as.character(nodeAttrs)
yeastGalactodeNodeIDs <- nodes(g)

g <- addNode("gal1RGexp", g)
styleList <- c("", "Yeast-Galactose"="yeastGalactoseStyle.js")
condition <- c("", "gal1RGexp", "gal4RGexp", "gal80Rexp")
#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  # includeScript("message-handler.js"),

  tags$head(
          tags$link(rel = "stylesheet", type = "text/css",
                    href = "http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css")),
  sidebarLayout(
      sidebarPanel(
          actionButton("fit", "Fit Graph"),
          hr(),
          selectInput("setNodeAttributes", "Select Condition:", choices=condition),
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

          selectInput("selectName", "Node ID:",
                      choices = c("", nodes(g))),
          actionButton("sfn", "Select First Neighbor"),
          actionButton("fitSelected", "Fit Selected"),
          actionButton("getSelectedNodes", "Get Selected Nodes"),
          actionButton("clearSelection", "Unselect Nodes"),

          hr(),
          actionButton("loopConditions", "Loop Conditions"),
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
       printf("about to sendCustomMessage, fit")
       fit(session, 80)
       #session$sendCustomMessage(type="fit", message=list(140))
       })

    observeEvent(input$setNodeAttributes, ignoreInit=TRUE, {
       printf("about to sendCustomMessage, redraw, setNodeAttributes")
       attribute <- "lfc"
       expression.vector <- switch(input$setNodeAttributes,
                                   "gal1RGexp" = tbl.mrna$gal1RGexp,
                                   "gal4RGexp" = tbl.mrna$gal4RGexp,
                                   "gal80Rexp" = tbl.mrna$gal80Rexp)
       setNodeAttributes(session, attributeName=attribute, nodes=yeastGalactodeNodeIDs, values=expression.vector)
       })

    observeEvent(input$loadStyleFile,  ignoreInit=TRUE, {
        printf("tinyApp.R, about to sendCustomMessage, loadStyle")
        if(input$loadStyleFile != "")
            loadStyleFile(input$loadStyleFile)
    })

    observeEvent(input$doLayout,  ignoreInit=TRUE,{
        printf("about to sendCustomMessage, doLayout")
        session$sendCustomMessage(type="doLayout", message=list(input$doLayout))
    })

    observeEvent(input$selectName,  ignoreInit=TRUE,{
        printf("about to sendCustomMessage, selectNodes")
        session$sendCustomMessage(type="selectNodes", message=list(input$selectName))
    })

    observeEvent(input$sfn,  ignoreInit=TRUE,{
        printf("about to sendCustomMessage, sfn")
        session$sendCustomMessage(type="sfn", message=list())
    })

    observeEvent(input$fitSelected,  ignoreInit=TRUE,{
        printf("about to call R function fitSelected")
        fitSelected(session, 100)
        #session$sendCustomMessage(type="fitSelected", message=list())
    })

    observeEvent(input$getSelectedNodes, ignoreInit=TRUE, {
        printf("about to sendCustomMessage, getSelectedNodes")
        session$sendCustomMessage(type="getSelectedNodes", message=list())
    })

    observeEvent(input$clearSelection,  ignoreInit=TRUE, {
        printf("about to sendCustomMessage, clearSelection")
        session$sendCustomMessage(type="clearSelection", message=list())
    })

    observeEvent(input$loopConditions, ignoreInit=TRUE, {
        printf("about to sendCustomMessage, setNodeAttributes")
        condition.names <- c("gal1RGexp", "gal4RGexp", "gal80Rexp")
        for(condition.name in condition.names){
           expression.vector <- tbl.mrna[, condition.name]
           setNodeAttributes(session, attributeName="lfc", nodes=yeastGalactodeNodeIDs, values=expression.vector)
           Sys.sleep(1)
           } # for condition.name
        updateSelectInput(session, "setNodeAttributes", selected="gal1RGexp")
        })

    output$value <- renderPrint({ input$action })
    output$cyjShiny <- renderCyjShiny(
        cyjShiny(graph)
    )

} # server
#----------------------------------------------------------------------------------------------------
graphToJSON <- function(g) #Copied from RCyjs/R/utils.R
{
   if(length(nodes(g)) == 0)
      return ("{}")

       # allocate more character vectors that we could ever need; unused are deleted at conclusion

    vector.count <- 10 * (length(edgeNames(g)) + length (nodes(g)))
    vec <- vector(mode="character", length=vector.count)
    i <- 1;

    vec[i] <- '{"elements": {"nodes": ['; i <- i + 1;
    nodes <- nodes(g)
    edgeNames <- edgeNames(g)
    edges <- strsplit(edgeNames, "~")  # a list of pairs
    edgeNames <- sub("~", "->", edgeNames)
    names(edges) <- edgeNames

    noa.names <- names(graph::nodeDataDefaults(g))
    eda.names <- names(graph::edgeDataDefaults(g))
    nodeCount <- length(nodes)
    edgeCount <- length(edgeNames)

    for(n in 1:nodeCount){
       node <- nodes[n]
       vec[i] <- '{"data": '; i <- i + 1
       nodeList <- list(id = node)
       this.nodes.data <- graph::nodeData(g, node)[[1]]
       if(length(this.nodes.data) > 0)
          nodeList <- c(nodeList, this.nodes.data)
       nodeList.json <- toJSON(nodeList, auto_unbox=TRUE)
       vec[i] <- nodeList.json; i <- i + 1
       if(all(c("xPos", "yPos") %in% names(graph::nodeDataDefaults(g)))){
          position.markup <- sprintf(', "position": {"x": %f, "y": %f}',
                                     graph::nodeData(g, node, "xPos")[[1]],
                                     graph::nodeData(g, node, "yPos")[[1]])
          vec[i] <- position.markup
          i <- i + 1
          }
        if(n != nodeCount){
           vec [i] <- "},"; i <- i + 1 # sprintf("%s},", x)  # another node coming, add a comma
           }
       } # for n

    vec [i] <- "}]"; i <- i + 1  # close off the last node, the node array ], the nodes element }

    if(edgeCount > 0){
       vec[i] <- ', "edges": [' ; i <- i + 1
       for(e in seq_len(edgeCount)) {
          vec[i] <- '{"data": '; i <- i + 1
          edgeName <- edgeNames[e]
          edge <- edges[[e]]
          sourceNode <- edge[[1]]
          targetNode <- edge[[2]]
          edgeList <- list(id=edgeName, source=sourceNode, target=targetNode)
          this.edges.data <- edgeData(g, sourceNode, targetNode)[[1]]
          if(length(this.edges.data) > 0)
             edgeList <- c(edgeList, this.edges.data)
          edgeList.json <- toJSON(edgeList, auto_unbox=TRUE)
          vec[i] <- edgeList.json; i <- i + 1
          if(e != edgeCount){          # add a comma, ready for the next edge element
             vec [i] <- '},'; i <- i + 1
             }
          } # for e
      vec [i] <- "}]"; i <- i + 1
      } # if edgeCount > 0

   vec [i] <- "}"  # close the edges object
   i <- i + 1;
   vec [i] <- "}"  # close the elements object
   vec.trimmed <- vec [which(vec != "")]
   #printf("%d strings used in constructing json", length(vec.trimmed))
   paste0(vec.trimmed, collapse=" ")

} # graphToJSON
#----------------------------------------------------------------------------------------------------------
graph <- graphToJSON(g)
app <- shinyApp(ui = ui, server = server)
