# r-cytoscape.js

##Basic Network
The basic example draws a small network, while using default options for the customizations. The examples make use of the R package [devtools](https://github.com/hadley/devtools), which allows users to source R scripts from GitHub. 

```
# Load devtools 
library(devtools) 

# Download functions
source_url("https://raw.githubusercontent.com/cytoscape/r-cytoscape.js/master/cytoscapeJsSimpleNetwork.R")

id <- c("Jerry", "Elaine", "Kramer", "George")
name <- id
nodeData <- data.frame(id, name, stringsAsFactors=FALSE)

source <- c("Jerry", "Jerry", "Jerry", "Elaine", "Elaine", "Kramer", "Kramer", "Kramer", "George")
target <- c("Elaine", "Kramer", "George", "Jerry", "Kramer", "Jerry", "Elaine", "George", "Jerry")
edgeData <- data.frame(source, target, stringsAsFactors=FALSE)

network <- createCytoscapeNetwork(nodeData, edgeData)
```

The resulting "network" object is a data.frame with information for the nodes and edges that is then passed on to cytoscapeJsSimpleNetwork. cytoscapeJsSimpleNetwork takes the JSON output and generates HTML code. The resulting HTML code can be a standalone webpage or HTML which can be embedded in [Shiny](http://shiny.rstudio.com/) apps.  

```
output <- cytoscapeJsSimpleNetwork(network$nodes, network$edges, standAlone=TRUE)
fileConn <- file("cytoscapeJsR_example.html")
writeLines(output, fileConn)
close(fileConn)
```

##Customizing Network

Customizing the network can be done by appending additional columns on to the original data.frames for the network. The current possible additional columns for nodes are "color", "shape", and "href" (an external link). The colors are hex colors and the options for shapes are from the [CytoscapeJS website](http://cytoscape.github.io/cytoscape.js/). For edges, the additional columns are: "color", "sourceShape", "targetShape". 

```
nodeData$color <- rep("#00FF00", nrow(nodeData)) 
nodeData$color[which(grepl("^Elaine$", nodeData$id))] <- "#FF0000"

nodeData$href <- paste0("http://www.google.com/search?q=Seinfeld%20", nodeData$name)

network <- createCytoscapeNetwork(nodeData, edgeData)

output <- cytoscapeJsSimpleNetwork(network$nodes, network$edges, standAlone=TRUE)
fileConn <- file("cytoscapeJsR_example.html")
writeLines(output, fileConn)
close(fileConn)
```

##Embedding in Shiny
It is possible embed Cytoscape.js networks into Shiny applications. The example in current GitHub repository shows a small network with proteins that interact with topoisomerase TOP1, as well as drugs that target the protein. With all the files downloaded and in the directory with the server.R and ui.R files, the example can be run as follows: 

```
library(shiny)
runApp()
```
