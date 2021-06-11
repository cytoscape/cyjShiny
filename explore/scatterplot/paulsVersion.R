library(shiny)

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
      xPoints <- sample(1:1000, 800, replace=TRUE)
      yPoints <- sample(1:1000, 800, replace=TRUE)
      plot(xPoints, yPoints, pch=19, col=point.color)
      })
}

runApp(shinyApp(ui, server))
