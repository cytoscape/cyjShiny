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
      point.color <- sample(colors, 3)
      seed <- set.seed(17)
      xPoints <- sample(1:100, replace=TRUE)
      yPoints <- sample(1:100,  replace=TRUE)
      plot(xPoints, yPoints, col=point.color,seed, type = "h")
      })
    
}

runApp(shinyApp(ui, server))