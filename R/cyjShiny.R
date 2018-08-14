#----------------------------------------------------------------------------------------------------
cyjShiny <- function(graph, width = NULL, height = NULL, elementId = NULL)
{
    printf("--- ~/github/cyjShiny/R/cyjShiny ctor");
    x <- list(
        graph = graph
    )

    # create widget
    htmlwidgets::createWidget(
                     name = 'cyjShiny',
                     x,
                     width = width,
                     height = height,
                     package = 'cyjShiny',
                     elementId = elementId
                 )

} # cyjShiny constructor
#----------------------------------------------------------------------------------------------------
cyjShinyOutput <- function(outputId, width = '100%', height = '400px')
{
  htmlwidgets::shinyWidgetOutput(outputId, 'cyjShiny', width, height, package = 'cyjShiny')
}
#----------------------------------------------------------------------------------------------------
renderCyjShiny <- function(expr, env = parent.frame(), quoted = FALSE)
{
   if (!quoted){
      expr <- substitute(expr)
      } # force quoted

  htmlwidgets::shinyRenderWidget(expr, cyjShinyOutput, env, quoted = TRUE)

}
#----------------------------------------------------------------------------------------------------
loadStyleFile <- function(filename)
{
   if(!file.exists(filename)){
      printf("cannot read style file: %s", filename)
      return;
      }

   jsonText <- toJSON(fromJSON(filename))
   print(jsonText)
   message <- list(json=jsonText)
   session <- shiny::getDefaultReactiveDomain()
   session$sendCustomMessage("loadStyle", message)

} # loadStyleFile
#------------------------------------------------------------------------------------------------------------------------
d
