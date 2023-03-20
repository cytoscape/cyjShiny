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

