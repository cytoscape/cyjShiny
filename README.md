# r-cytoscape.js

## Overview 

An [HTMLWidgets](http://www.htmlwidgets.org/) package for CytoscapeJS which can be used to produce standalone figure or for embedding in [Shiny](http://shiny.rstudio.com/) applications. 

## Install
This package is currently not on CRAN, but you can install it from GitHub via `devtools`:

```r
library("devtools");
devtools::install_github("cytoscape/r-cytoscape.js");
```

## Sample network
```
# Load devtools 
library(rcytoscapejs)

id <- c("Jerry", "Elaine", "Kramer", "George")
name <- id
nodeData <- data.frame(id, name, stringsAsFactors=FALSE)

source <- c("Jerry", "Jerry", "Jerry", "Elaine", "Elaine", "Kramer", "Kramer", "Kramer", "George")
target <- c("Elaine", "Kramer", "George", "Jerry", "Kramer", "Jerry", "Elaine", "George", "Jerry")
edgeData <- data.frame(source, target, stringsAsFactors=FALSE)

network <- createCytoscapeJsNetwork(nodeData, edgeData)
rcytoscapejs(network$nodes, network$edges, showPanzoom=FALSE)
```
##Customizing Network

Customizing the network can be done by appending additional columns on to the original data.frames for the network. The current possible additional columns for nodes are "color", "shape", and "href" (an external link). The colors are hex colors and the options for shapes are from the [CytoscapeJS website](http://cytoscape.github.io/cytoscape.js/). For edges, the additional columns are: "color", "sourceShape", "targetShape". 

```
nodeData$color <- rep("#00FF00", nrow(nodeData)) 
nodeData$color[which(grepl("^Elaine$", nodeData$id))] <- "#FF0000"

nodeData$href <- paste0("http://www.google.com/search?q=Seinfeld%20", nodeData$name)

network <- createCytoscapeJsNetwork(nodeData, edgeData)

cytoscapeJsSimpleNetwork(network$nodes, network$edges)
```

##Embedding in Shiny

It is possible embed Cytoscape.js networks into [Shiny applications](http://shiny.rstudio.com/). The example in current GitHub repository shows a small network with proteins that interact with topoisomerase TOP1, as well as drugs that target the protein. The example Shiny app can be run with the following commands and is stored in inst/examples.

```
library(shiny)
runShinyApp()
```

CytoscapeJS possesses many options that are not all captured in the HTMLWidgets functionality; users can fork this repository and edit inst/htmlwidgets/rcytoscapejs.js The sample showcases the use tooltips (from "href" data column), usage of Cytoscape plugins (i.e. panzoom and qtip), returning values from click events on network. 
 
