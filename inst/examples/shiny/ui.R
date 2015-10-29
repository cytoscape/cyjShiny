shinyUI(navbarPage("R Cytoscape Example",
  tabPanel("Network",
    h4("Clicked Node"),
    verbatimTextOutput("clickedNode"),
    h4("Connected Nodes"),
    verbatimTextOutput("connectedNodes"),
    h4("Network"),
    rcytoscapejsOutput("plot",height="600px"),
    hr(),
    h4("Clicked Node Data"),
    dataTableOutput("nodeDataTable"),
    hr(),
    h4("Data for Edges between Connected Nodes"),
    dataTableOutput("edgeDataTable")
  )
  #tags$head(includeScript("www/js/google-analytics.js"))
))

