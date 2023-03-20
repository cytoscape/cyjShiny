![R-CMD-check](https://github.com/cytoscape/cyjShiny/actions/workflows/R-CMD-check.yaml/badge.svg)

## cyjShiny

cyjShiny is a Shiny widget based on [htmlWidgets](http://www.htmlwidgets.org/index.html]) for network visualization using [cytoscape.js](https://js.cytoscape.org/).

## Installation
### From CRAN (Stable Version) 

Users should start with CRAN as it is the most stable version: 

```
install.packages("cyjShiny") 
```

### Install from GitHub (Development Version) 
```
library(remotes)
remotes::install_github(repo="cytoscape/cyjShiny", ref="master", build_vignette=TRUE)
```

### Compile cytoscape.js (Javascript Development) 

[Instructions](https://github.com/cytoscape/cyjShiny/wiki/installation) for compiling cytoscape.js for use with htmlWidgets. NOTE: This should only be used by those actively modifying [cytoscape.js](https://js.cytoscape.org/).

## Quick Start (First cyjShiny App)

* [Shiny Development Basics](https://shiny.rstudio.com/tutorial/) 
* [Shiny Extensions for Embedding Javascript Visualizations](https://shiny.rstudio.com/articles/htmlwidgets.html)
* Get help: `help(package="cyjShiny")`

```
library(shiny)
library(cyjShiny)
library(graph)
library(jsonlite)

# NETWORK DATA ----
tbl_nodes <- data.frame(id=c("A", "B", "C"), 
                        type=c("dna", "rna", "protein"),
                        stringsAsFactors=FALSE)

# Must have the interaction column 
tbl_edges <- data.frame(source=c("A", "B", "C"),
                        target=c("B", "C", "A"),
                        interaction=c("interacts", "stimulates", "inhibits"),
                        stringsAsFactors=FALSE)

graph_json <- toJSON(dataFramesToJSON(tbl_edges, tbl_nodes), auto_unbox=TRUE)

# UI ----
ui <- fluidPage(cyjShinyOutput('cyjShiny'))

# SERVER ----
server <- function(input, output, session) {
  output$cyjShiny <- renderCyjShiny({
    cyjShiny(graph=graph_json, layoutName="cola")
  })
}

# RUN ----
shinyApp(ui=ui, server=server)
```

## Demo 

* Try [Demo](https://cannin.shinyapps.io/cyjShiny/) on [shinyapps.io](https://www.shinyapps.io/)
* Demo [Code](https://github.com/cytoscape/cyjShiny/tree/master/inst/demos/basicDemo)

<img src="inst/docs/ygModelImage.png" height="480px" />
