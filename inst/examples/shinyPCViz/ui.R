library(rcytoscapejs)
library(shiny)

shinyUI(navbarPage("Shiny PCViz",
  tabPanel("Network",
    sidebarLayout(
      sidebarPanel(
        fileInput('sifFile', 'Choose SIF File', accept=c('.sif')),
        hr(),
        h4("Hover Node"),
        textOutput("clickedNode"),
        hr(),
        h4("Clicked Interaction Type"),
        textOutput("clickedEdge"),
        width=3
      ),
      mainPanel(
        rcytoscapejsOutput("plot", height="600px")
      )
    )
  ),
  tags$head(tags$script(src="cyjs.js"))
))

