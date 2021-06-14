
library(shiny)
options(shiny.host = '0.0.0.0')
options(shiny.port = 8888)
set.seed(17)

ui <- fluidPage(
    titlePanel("Scatterplot Demo"),
        actionButton("newPlotButton", "New Plot"),
        plotOutput(outputId = "scatterplot")
    )


server <- function(input, output) {

    output$scatterplot <- renderPlot({
      input$newPlotButton   # just this mention of #newPlotButton triggers this block of code
      colors <- c("red", "blue", "green", "orange", "brown", "black")
      point.color <- sample(colors, 1)
      xPoints <- sample(1:100, replace=TRUE)
      yPoints <- sample(1:100,  replace=TRUE)
      plot(xPoints, yPoints, col=point.color)
      })


}

app <- shinyApp(ui = ui, server = server)
#app <-runApp(shinyApp(ui = ui, server = server), port=9870)
#if(!interactive())
#    runApp(app, port=9876)

