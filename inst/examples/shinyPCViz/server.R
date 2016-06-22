library(rcytoscapejs)
library(paxtoolsr)
library(DT)

shinyServer(function(input, output, session) {
  # NOTE: Reactive variables used as functions networkReactive()
  networkReactive <- reactive({
    shiny::validate(
      need(!is.null(input$sifFile), "SIF Missing")
    )
    
    inFile <- input$sifFile
    
    network <- read.table(inFile$datapath, sep="\t", stringsAsFactors=FALSE)
    colnames(network) <- c("source", "interaction", "target")
    
    sif <- network
    colnames(sif) <- c("PARTICIPANT_A", "INTERACTION_TYPE", "PARTICIPANT_B")
    
    #maxInteractions <-  input$maxInteractions
    maxInteractions <- 50
    
    if(nrow(network) <= maxInteractions) {
      maxInteractions <- nrow(network)
    } else {
      maxInteractions <- maxInteractions
    }
    
    network <- network[1:maxInteractions, ]
    
    edgeList <- network[, c("source","target")]
    
    nodes <- unique(c(edgeList$source, edgeList$target))
    
    id <- nodes
    name <- nodes
    addLinks <- TRUE
    
    if(addLinks) {
      href <- paste0("https://www.google.com/search?q=", nodes)
      tooltip <- paste0("Node: ", nodes)
      nodeData <- data.frame(id, name, href, tooltip, stringsAsFactors=FALSE)
    } else {
      nodeData <- data.frame(id, name, stringsAsFactors=FALSE)
    }
    
    nodeData$color <- rep("#888888", nrow(nodeData))
    nodeData$color[which(grepl("[a-z]", nodes))] <- "#FF0000"
    
    nodeData$shape <- rep("ellipse", nrow(nodeData))
    nodeData$shape[which(grepl("[a-z]", nodes))] <- "octagon"
    
    edgeData <- edgeList
    
    tmp <- list(nodeData=nodeData, edgeData=edgeData, sif=sif)
    
    return(tmp)
  })
  
  output$clickedNode = renderPrint({
    input$clickedNode
  })
  
  output$clickedEdge = renderPrint({
    network <- networkReactive()
    
    t1 <- input$clickedEdge
    t2 <- data.frame(a=t1[1], b=t1[2], stringsAsFactors=FALSE)
    
    shiny::validate(
      need(!is.null(input$clickedEdge), "NULL")
    )
    
    #str(t1)
    #str(t2)
    
    sif <- filterSif(network$sif, edgelist=t2)
    #str(sif$INTERACTION_TYPE)
    
    unique(sif$INTERACTION_TYPE)
  })
  
  output$plot <- renderRcytoscapejs({
    network <- networkReactive()
    
    cyNetwork <- createCytoscapeJsNetwork(network$nodeData, network$edgeData)
    rcytoscapejs(nodeEntries=cyNetwork$nodes, edgeEntries=cyNetwork$edges, highlightConnectedNodes=FALSE)
  })
})
