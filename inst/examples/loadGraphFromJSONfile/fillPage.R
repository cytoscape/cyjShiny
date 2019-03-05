library(shiny)
ui <- fillPage(
  tags$style(type = "text/css",
    ".half-fill { width: 50%; height: 100%; }",
    "#one { float: left; background-color: #ddddff; }",
    "#two { float: right; background-color: #ccffcc; }"
  ),
  div(id = "one", class = "half-fill",
    "Left half"
  ),
  div(id = "two", class = "half-fill",
    "Right half"
  ),
  padding = 10
)

server = function(input, output, session)
{
}

app <- shinyApp(ui=ui, server=server)
