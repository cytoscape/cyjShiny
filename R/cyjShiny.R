#----------------------------------------------------------------------------------------------------
cyjShiny <- function(message, width = NULL, height = NULL, elementId = NULL)
{
  printf("--- ~/github/cyjShiny/R/cyjShiny ctor");
  x <- list(
    message = message
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
   message <- list(filename=filename)
   session <- shiny::getDefaultReactiveDomain()
   session$sendCustomMessage("loadStyleFile", message)

} # loadStyleFile
#------------------------------------------------------------------------------------------------------------------------

