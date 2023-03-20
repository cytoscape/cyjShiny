library(shiny)
library(cyjShiny)
library(graph)
library(jsonlite)

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

# UI ----
ui <- fluidPage(cyjShinyOutput('cyjShiny'))

# SERVER ----
server <- function(input, output, session) {
  output$cyjShiny <- renderCyjShiny({
    # Layouts (see js.cytoscape.org): cola, cose, circle, concentric, grid, breadthfirst, random, dagre, cose-bilkent
    cyjShiny(graph_json, layoutName="cola")
  })
}

# RUN ----
shinyApp(ui=ui, server=server)
