#----------------------------------------------------------------------------------------------------
#' Constructor for the cyjShiny widget
#'
#' @param graph an R graphNEL instance (igraph support coming soon)
#' @param width integer  initial width of the widget
#' @param height integer initial height of the widget
#' @param elementId string the DOM id into which the widget is rendered, default NULL is best
#'
#' @return a reference to an htmlwidget
#'
#' @export
#'
#' @examples
#'   in ui:
#'     mainPanel(cyjShinyOutput('cyjShiny'), width=10)
#'
#'   in server:
#'      ouptu$cyjShiny <- renderCyjShiny(cyjShiny(graph))
#'
#'
#' @aliases cyjShiny
#' @rdname cyjShiny
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
#' Standard shiny ui rendering construct
#'
#' @param outputID the name of the DOM element to create
#' @param width integer  optional initial width of the widget
#' @param height integer optional initial height of the widget
#'
#' @return a reference to an htmlwidget
#'
#' @export
#'
#' @examples
#'   in ui:
#'     mainPanel(cyjShinyOutput('cyjShiny'), width=10)
#'
#'   in server:
#'      ouptu$cyjShiny <- renderCyjShiny(cyjShiny(graph))
#'
#'
#' @aliases cyjShinyOutput
#' @rdname cyjShinyOutput
#----------------------------------------------------------------------------------------------------
cyjShinyOutput <- function(outputId, width = '100%', height = '400px')
{
  htmlwidgets::shinyWidgetOutput(outputId, 'cyjShiny', width, height, package = 'cyjShiny')
}
#----------------------------------------------------------------------------------------------------
#' More shiny plumbing - now sure exactly what this does
#'
#' @param expr not sure...
#' @param env environment not sure ...
#' @param quoteed logical not sure ...
#'
#' @return not sure
#'
#' @export
#'
#' @aliases renderCyjShiny
#' @rdname renderCyjShiny
#----------------------------------------------------------------------------------------------------
renderCyjShiny <- function(expr, env = parent.frame(), quoted = FALSE)
{
   if (!quoted){
      expr <- substitute(expr)
      } # force quoted

  htmlwidgets::shinyRenderWidget(expr, cyjShinyOutput, env, quoted = TRUE)

}
#----------------------------------------------------------------------------------------------------
#' load a standard cytoscape.js style file
#'
#' @param filename character string, either relative or absolute path
#'
#' @return nothing
#'
#' @export
#'
#' @examples
#'
#' loadStyleFile(system.file(package="cyjShiny", "extdata", "yeastGalactoseStyle.js"))
#'
#' @aliases loadStyleFile
#' @rdname loadStyleFile
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
#' Set zoom and center of the graph display so that graph fills the display
#'
#' @param session a Shiny server session object
#' @param padding integer, default 50 pixels
#'
#' @export
#'
#' @examples
#'
#'   fit(session, 100)
#'
#' @aliases fit
#' @rdname fit
#'
#' @seealso\code{\link{fitSelected}}
#----------------------------------------------------------------------------------------------------
fit <- function(session, padding=50)
{
   session$sendCustomMessage("fit", list(padding=padding))

} # fitSelected
#------------------------------------------------------------------------------------------------------------------------
#' Set zoom and center of the graph display so that the currently selected nodes fill the display
#'
#' @param session  a Shiny server session object
#' @param padding integer, default 50 pixels
#'
#' @export
#'
#' @examples
#'
#'   fitSelected(session, 100)
#'
#' @aliases fitSelected
#' @rdname fitSelected
#'
#' @seealso\code{\link{fit}}
#'
#----------------------------------------------------------------------------------------------------
fitSelected <- function(session, padding=50)
{
   session$sendCustomMessage("fitSelected", list(padding=padding))

} # fitSelected
#------------------------------------------------------------------------------------------------------------------------
#' Assign the supplied node attribute values to the graph structure contained in the browser
#'
#' @param session a Shiny Server session object
#' @param attributeName character string, the attribute to update
#' @param nodes a character vector the names of the nodes whose attributes are updated
#' @param values a character, logical or numeric vector, the new values
#'
#' @export
#'
#' @examples
#'   setNodeAttributes(session,
#'                     attributeName=attribute,
#'                     nodes=yeastGalactodeNodeIDs,
#'                     values=expression.vector)
#'
#' @aliases setNodeAttributes
#' @rdname setNodeAttributes
#----------------------------------------------------------------------------------------------------
setNodeAttributes <- function(session, attributeName, nodes, values)
{
   session$sendCustomMessage(type="setNodeAttributes",
                             message=list(attribute=attributeName,
                                          nodes=nodes,
                                          values=values))
} # setNodeAttributes
#------------------------------------------------------------------------------------------------------------------------
#' Layout the current graph using the specified strategy.
#'
#' @param session a Shiny Server session object
#' @param layoutStrategy character string, one of cola, cose, circle, concentric, grid, breadthfirst, random, dagre, cose-bilkent
#'
#' @export
#'
#' @examples
#'   doLayout(session, "cola")
#'
#' @aliases doLayout
#' @rdname doLayout
#----------------------------------------------------------------------------------------------------
doLayout <- function(session, strategy)
{
   stopifnot(strategy %in% c("cola", "cose", "circle", "concentric", "grid", "breadthfirst", "random",
                             "dagre", "cose-bilkent"))

   session$sendCustomMessage(type="doLayout", message=list(strategy=strategy))

} # doLayout
#------------------------------------------------------------------------------------------------------------------------
