library(shiny)

shinyServer(function(input, output, session) {
    source("./cytoscapeJsSimpleNetwork.R")
        
    output$cytoscapeJsPlot <- renderPrint({
        network <- read.table("./cbioportal_top1.sif", sep="\t", 
                              stringsAsFactors=FALSE)
        colnames(network) <- c("source", "interaction", "target")
        
        if(nrow(network) <= input$maxInteractions) {
            maxInteractions <- nrow(network)
        } else {
            maxInteractions <- input$maxInteractions
        }
        
        network <- network[1:maxInteractions, ]
        edgeList <- network[, c("source","target")]
        
        nodes <- unique(c(edgeList$source, edgeList$target))
        
        id <- nodes
        name <- nodes
        
        if(input$addLinks) {
            href <- paste0("https://www.google.com/search?q=", nodes)
            nodeData <- data.frame(id, name, href, stringsAsFactors=FALSE)            
        } else {
            nodeData <- data.frame(id, name, stringsAsFactors=FALSE)            
        }
        
        nodeData$color <- rep("#888888", nrow(nodeData)) 
        nodeData$color[which(grepl("[a-z]", nodes))] <- "#FF0000"

        nodeData$shape <- rep("ellipse", nrow(nodeData)) 
        nodeData$shape[which(grepl("[a-z]", nodes))] <- "octagon"

        edgeData <- edgeList
        
        cyNetwork <- createCytoscapeNetwork(nodeData, edgeData)
        cytoscapeJsSimpleNetwork(cyNetwork$nodes, cyNetwork$edges, layout=input$layout)
    })
})
