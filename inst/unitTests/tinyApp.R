library(shiny)
library(cyjShiny)
library(htmlwidgets)
library(graph)
library(jsonlite)
#----------------------------------------------------------------------------------------------------
nodeCount <- 2
edgeCount <- 2

elementCount <- nodeCount^2;
vec <- rep(0, elementCount)

set.seed(13);
vec[sample(1:elementCount, edgeCount)] <- 1
mtx <- matrix(vec, nrow=nodeCount)

gam <- graphAM(adjMat=mtx, edgemode="directed")
gnel <- as(gam, "graphNEL")

#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  # includeScript("message-handler.js"),

  tags$head(
          tags$link(rel = "stylesheet", type = "text/css",
                    href = "http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css")),
  sidebarLayout(
     sidebarPanel(
        actionButton("selectNodes", "Select Nodes"),
        actionButton("loadStyleFileButton", "LOAD style.js"),
        actionButton("hideSelectedNodes", "Hide Selected Nodes"),
        actionButton("getNodes", "Get Node Names"),
        actionButton("hideAllEdges", "Change Background"),
        actionButton("sendMtx", "Send Matrix"),

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
    observeEvent(input$selectNodes, {
        printf("about to sendCustomMessage, selectNodes")
        session$sendCustomMessage(type="selectNodes", message=list("a", "b"))
    })

    #observeEvent(input$sendMtx, {
     #   printf("about to sendCustomMessage, sendMtx")
      #  session$sendCustomMessage(type="sendMtx", data = data)
       # })

    observeEvent(input$hideSelectedNodes, { #DOESNT WORK
        printf("about sendCustomMessage, hideSelectedNodes")
        session$sendCustomMessage(type="hideSelectedNodes", message=list())
        })

    observeEvent(input$getNodes, { #DOESNT WORK
        printf("about to sendCustomMessage, getNodes")
        session$sendCustomMessage(type="getNodes", message=(list("all")))
    })

    observeEvent(input$hideAllEdges, {
        printf("about to sendCustomMessage, setBackgroundColor") #DOESNT WORK
        session$sendCustomMessage(type="setBackgroundColor", message=list("lightblue"))
        })
    
    observeEvent(input$loadStyleFileButton, { #DOESNT WORK
        printf("about to sendCustomMessage, loadStyleFile")
        session$sendCustomMessage(type="loadStyleFile", message=(list(filename="style.js")))
    })
    
    
    output$value <- renderPrint({ input$action })
    output$cyjShiny <- renderCyjShiny(
        cyjShiny(graph)
    )
    
} # server
#----------------------------------------------------------------------------------------------------
showRegion <- function(roi)
{

} # showRegion
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
shinyApp(ui = ui, server = server)


graph <- graphToJSON(gnel)
