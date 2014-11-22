library(shiny)

shinyUI(fluidPage(
    tags$head(
        tags$script(src = 'http://cytoscape.github.io/cytoscape.js/api/cytoscape.js-latest/cytoscape.min.js'),
        tags$script(src = 'http://cytoscape.github.io/cytoscape.js/api/cytoscape.js-latest/cola.v3.min.js'), 
        tags$script(src = 'http://cytoscape.github.io/cytoscape.js/api/cytoscape.js-latest/springy.js'), 
        tags$script(src = 'http://cytoscape.github.io/cytoscape.js/api/cytoscape.js-latest/dagre.js')         
    ),
    
    # Application title
    titlePanel("Cytoscape JS in R"),
    
    sidebarLayout(
        sidebarPanel(width=3, 
            sliderInput("maxInteractions", "Maximum Interactions:", min=1, max=75, value=10),
            selectInput("layout", "Layout:", 
                        choices=c("grid", "random", "circle", "breadthfirst", "cose", "springy", "cola", "dagre"), 
                        selected="grid", 
                        multiple=FALSE),
            checkboxInput("addLinks", "Add Links on Nodes?", TRUE)
        ),
        
        mainPanel(div(id="cy"), htmlOutput("cytoscapeJsPlot"))
    )
))
