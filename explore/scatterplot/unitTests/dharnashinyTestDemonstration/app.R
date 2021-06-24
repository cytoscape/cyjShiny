library(shiny)

ui <- fluidPage(
        tags$head(
        # Note the wrapping of the string in HTML()
        tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Yusei+Magic&display=swap');
      body {
        background-color: white;
        color: black;
      }
      h2 {
        font-family: 'Yusei Magic', sans-serif;
      }
      .shiny-input-container {
        color: #474747;
      }"))
    ),
    titlePanel("Scatterplot Demo"),
       actionButton("newPlotButton", "New Plot"),
       plotOutput(outputId = "scatterplot")
       )


server <- function(input, output) {

    set.seed(17)

    output$scatterplot <- renderPlot({
      input$newPlotButton   # just this mention of #newPlotButton triggers this block of code
      colors <- c("red", "blue", "green", "orange", "brown", "black")
      point.color <- sample(colors, 1)
      xPoints <- sample(1:100, replace=TRUE)
      yPoints <- sample(1:100,  replace=TRUE)
      plot(xPoints, yPoints, col=point.color, pch=19, cex=3)
      })


}

shinyApp(ui = ui, server = server)