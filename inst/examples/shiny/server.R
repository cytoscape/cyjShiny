library(rcytoscapejs)
library(DT)

shinyServer(function(input, output, session) {
  network <- read.table("cbioportal_top1.sif", sep="\t", stringsAsFactors=FALSE)
  
  colnames(network) <- c("source", "interaction", "target")
  
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
    tooltip <- paste0("https://www.google.com/search?q=", nodes)
    nodeData <- data.frame(id, name, href, tooltip, stringsAsFactors=FALSE)
  } else {
    nodeData <- data.frame(id, name, stringsAsFactors=FALSE)
  }
  
  nodeData$color <- rep("#888888", nrow(nodeData))
  nodeData$color[which(grepl("[a-z]", nodes))] <- "#FF0000"
  
  nodeData$shape <- rep("ellipse", nrow(nodeData))
  nodeData$shape[which(grepl("[a-z]", nodes))] <- "octagon"
  
  edgeData <- edgeList
  
  # NOTE: Reactive variables used as functions networkReactive()
  networkReactive <- reactive({
    if(is.null(input$connectedNodes)) {
      return(network)
    } else {
      t1 <- which(network$source %in% input$connectedNodes)
      t2 <- which(network$target %in% input$connectedNodes)
      idx <- unique(c(t1, t2))
      return(network[idx,])
    }
  })
  
  output$nodeDataTable <- DT::renderDataTable({
    tmp <- nodeData[which(id == input$clickedNode),]
    DT::datatable(tmp, filter='bottom', style='bootstrap', options=list(pageLength=5))
  })
  
  output$edgeDataTable <- DT::renderDataTable({
    DT::datatable(networkReactive(), filter='bottom', style='bootstrap', options=list(pageLength=5))
  })
  
  output$clickedNode = renderPrint({
    input$clickedNode
  })
  
  output$connectedNodes = renderPrint({
    input$connectedNodes
  })
  
  output$plot <- renderRcytoscapejs({
    cyNetwork <- createCytoscapeJsNetwork(nodeData, edgeData)
    rcytoscapejs(nodeEntries=cyNetwork$nodes, edgeEntries=cyNetwork$edges)
  })
  
  observeEvent(input$saveImage, {
    # NOTE: Message cannot be an empty string "", nothing will happen    
    session$sendCustomMessage(type="saveImage", message="NULL")
  })
})
