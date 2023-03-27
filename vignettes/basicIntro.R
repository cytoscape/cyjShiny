## ----setup, include = FALSE---------------------------------------------------
options(width=120)
knitr::opts_chunk$set(
   collapse = TRUE,
   eval=interactive(),
   echo=TRUE,
   comment = "#>"
)


## -----------------------------------------------------------------------------
library(cyjShiny)

# NETWORK DATA ----
tbl_nodes <- data.frame(id=c("A", "B", "C"), 
                        size=c(10, 20, 30),
                        stringsAsFactors=FALSE)

# Must have the interaction column 
tbl_edges <- data.frame(source=c("A", "B", "C"),
                        target=c("B", "C", "A"),
                        interaction=c("inhibit", "stimulate", "inhibit"),
                        stringsAsFactors=FALSE)

graph_json <- toJSON(dataFramesToJSON(tbl_edges, tbl_nodes), auto_unbox=TRUE)

# graph_json is a string with JSON content that is input to cytoscape.js
print(graph_json)

cyjShiny(graph=graph_json, layoutName="cola")


## -----------------------------------------------------------------------------
style_file <- system.file(file.path("demos", "rmarkdownDemo", "style.js"), package="cyjShiny")
cyjShiny(graph_json, layoutName="cola", styleFile=style_file)


## -----------------------------------------------------------------------------
yeast_galactose_style_file <- system.file(file.path("demos", "rmarkdownDemo", "yeastGalactoseStyle.js"), package="cyjShiny")
yeast_galactose_graph <- readLines(system.file(file.path("demos", "rmarkdownDemo", "yeastGalactose.cyjs"), package="cyjShiny"))

cyjShiny(yeast_galactose_graph, layoutName="fcose", styleFile=yeast_galactose_style_file)


## -----------------------------------------------------------------------------
style_file <- system.file(file.path("demos", "rmarkdownDemo", "preset_style.js"), package="cyjShiny")
graph_json <- readLines(system.file(file.path("demos", "rmarkdownDemo", "preset_graph.js"), package="cyjShiny"))
cyjShiny(graph_json, layoutName="preset", styleFile=style_file)


## -----------------------------------------------------------------------------
preset_graph_file <- system.file(file.path("demos", "fromCytoscapeDesktop", "small", "cyjshiny.cyjs"), package="cyjShiny")
graph_json <- readAndStandardizeJSONNetworkFile(preset_graph_file)
writeLines(graph_json, "cyjshiny_cytoscape_desktop.cyjs")

cyjShiny(graph_json, layoutName="preset")


## ----app, prompt=TRUE, message=TRUE, results="hold", eval=FALSE---------------
## library(shiny)
## library(cyjShiny)
## library(graph)
## library(jsonlite)
## 
## # NETWORK DATA ----
## tbl_nodes <- data.frame(id=c("A", "B", "C"),
##                         size=c(10, 20, 30),
##                         stringsAsFactors=FALSE)
## 
## # Must have the interaction column
## tbl_edges <- data.frame(source=c("A", "B", "C"),
##                         target=c("B", "C", "A"),
##                         interaction=c("inhibit", "stimulate", "inhibit"),
##                         stringsAsFactors=FALSE)
## 
## graph_json <- toJSON(dataFramesToJSON(tbl_edges, tbl_nodes), auto_unbox=TRUE)
## 
## # UI ----
## ui <- fluidPage(cyjShinyOutput('cyjShiny'))
## 
## # SERVER ----
## server <- function(input, output, session) {
##   output$cyjShiny <- renderCyjShiny({
##     # Layouts (see js.cytoscape.org): cola, cose, circle, concentric, grid, breadthfirst, random, fcose, spread
##     cyjShiny(graph_json, layoutName="cola")
##   })
## }
## 
## # RUN ----
## shinyApp(ui=ui, server=server)

