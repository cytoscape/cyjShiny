library(shiny)
library(cyjShiny)
library(htmlwidgets)
library(graph)
library(jsonlite)

source("organize.R")
source("sepDate.R")
source("analysis.R")

staffList <- read.table("isbAllStaff",header=FALSE, sep="\t", fill=TRUE)
#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  # includeScript("message-handler.js"),

  tags$head(
          tags$link(rel = "stylesheet", type = "text/css",
                    href = "http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css")),
  sidebarLayout(
      sidebarPanel(
          actionButton("fit", "Fit Graph"),
          br(),
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
                                
          selectInput("selectName", "Node Name:",
                      choices = staffList[[1]]),
          actionButton("selectNodes", "Select Node"),
          actionButton("clearSelection", "Unselect Nodes"),
          actionButton("loadStyleFileButton", "LOAD style.js"),
          actionButton("getSelectedNodes", "Get Selected Nodes"),
          actionButton("sfn", "Select First Neighbor"),
          
          hr(),
          width=2
      ),
      mainPanel(
          cyjShinyOutput('cyjShiny'),
          width=10
      )
  ) # sidebarLayout
))
#----------------------------------------------------------------------------------------------------
server = function(input, output, session)
{
    observeEvent(input$doLayout, {
        printf("about to sendCustomMessage, doLayout")
        session$sendCustomMessage(type="doLayout", message=list(input$doLayout))
    })
    
    observeEvent(input$selectNodes, {
        printf("about to sendCustomMessage, selectNodes")
        session$sendCustomMessage(type="selectNodes", message=list(input$selectName))
    })

    observeEvent(input$clearSelection, {
        printf("about to sendCustomMessage, clearSelection")
        session$sendCustomMessage(type="clearSelection", message=list())
    })
    
    observeEvent(input$loadStyleFileButton, { #DOESNT WORK
        printf("about to sendCustomMessage, loadStyleFile")
        session$sendCustomMessage(type="loadStyleFile", message=(list(filename="style.js")))
    })

    observeEvent(input$getSelectedNodes, {
        printf("about to sendCustomMessage, getSelectedNodes")
        session$sendCustomMessage(type="getSelectedNodes", message=list())
    })

    observeEvent(input$fit, {
        printf("about to sendCustomMessage, fit")
        session$sendCustomMessage(type="fit", message=list(50))
    })

    observeEvent(input$sfn, {
        printf("about to sendCustomMessage, sfn")
        session$sendCustomMessage(type="sfn", message=list())
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

} # .graphToJSON
#------------------------------------------------------------------------------------------------------------------------
loadData <- function()
{
    load("interaction_bundle-2018-07-30.RData")

    week <- "all"  # "all", 1, 2, 3, 4, 5, 6
    
    tbl <- fixTbl(tbl) #organize.R
    
    if(week != "all")
        tbl <- s.date(tbl, week) #sepDate.R
    
    tbl$signature <- paste(tbl$a, tbl$b, sep=":")
    
    gnel <- new("graphNEL", edgemode = "undirected")
                                        #gnel <- new("graphNEL", edgemode = "directed")
    
    all.nodes <- c(unique(c(tbl$a, tbl$b)))
    duplicated.interactions <- which(duplicated(tbl$signature))
    tbl.unique <- tbl[-duplicated.interactions,]
    
    gnel <- addNode(all.nodes, gnel)
    gnel <- graph::addEdge(tbl.unique$a, tbl.unique$b, gnel)
    
    #gi <- igraph.from.graphNEL(gnel, name = TRUE, weight = TRUE, unlist.attrs = TRUE)
    #newman <- community.newman(gi) #analysis.R
    #print(head(newman))
    
    #nodeDataDefaults(gnel, attr = "type") <- "undefined"
    #nodeDataDefaults(gnel, attr="newman") <- 0
    #edgeDataDefaults(gnel, attr = "count") <- 0
    
    #nodeData(gnel, nodes(gnel), attr="newman") <- newman
    
    g.json <- graphToJSON(gnel)

    g.json
}#loadData
#------------------------------------------------------------------------------------------

graph <- loadData()

shinyApp(ui = ui, server = server)
