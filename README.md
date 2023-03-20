![R-CMD-check](https://github.com/cytoscape/cyjShiny/actions/workflows/R-CMD-check.yaml/badge.svg)

## cyjShiny

cyjShiny is a Shiny widget (based on (htmlWidgets)[http://www.htmlwidgets.org/index.html]) for network visualization using [cytoscape.js](https://js.cytoscape.org/).

## Installation
### From CRAN (Stable Version) 

Users should start with CRAN as it is the most stable version: 

```
install.packages("cyjShiny") 
```

# Install from GitHub (Development Version) 
```
library(remotes)
remotes::install_github(repo="cytoscape/cyjShiny", ref="master", build_vignette=TRUE)
```

### Compile cytoscape.js (Javascript Development) 

[Instructions](https://github.com/cytoscape/cyjShiny/wiki/installation) for compiling cytoscape.js for use with htmlWidgets. NOTE: This should only be used by those actively modifying [cytoscape.js](https://js.cytoscape.org/).

## Quick Start (First cyjShiny App)

* [Shiny Development Basics](https://shiny.rstudio.com/tutorial/) 
* [Shiny Extensions for Embedding Javascript Visualizations](https://shiny.rstudio.com/articles/htmlwidgets.html)

```
library(shiny)
library(cyjShiny)
library(htmlwidgets)
library(graph)
library(jsonlite)

# NETWORK DATA ----
tbl.nodes <- data.frame(id=c("A", "B", "C"),
                        type=c("kinase", "TF", "glycoprotein"),
                        lfc=c(-3, 1, 1),
                        count=c(0, 0, 0),
                        stringsAsFactors=FALSE)

tbl.edges <- data.frame(source=c("A", "B", "C"),
                        target=c("B", "C", "A"),
                        interaction=c("phosphorylates", "synthetic lethal", "unknown"),
                        stringsAsFactors=FALSE)

graph.json <- toJSON(dataFramesToJSON(tbl.edges, tbl.nodes), auto_unbox=TRUE)

# UI ----
ui = shinyUI(fluidPage(

    cyjShinyOutput('cyjShiny'),
    width=10
    )
)

# SERVER ----
server = function(input, output, session)
{
    output$cyjShiny <- renderCyjShiny({
       cyjShiny(graph=graph.json, layoutName="cola")
       })

}

# RUN ----
runApp(shinyApp(ui=ui, server=server), port=9999)
```

## Demo 

Try [Demo](https://cannin.shinyapps.io/cyjShiny/); Example [Code](https://github.com/cytoscape/cyjShiny/tree/master/inst/demos/basicDemo)

![model](inst/docs/ygModelImage.png | height=640)
