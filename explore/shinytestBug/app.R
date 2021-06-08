
library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Plot"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("plot1", click = "plot_click"),
           verbatimTextOutput("info")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$plot1 <- renderPlot({
        plot(1:10,1:10)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)