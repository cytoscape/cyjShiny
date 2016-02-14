#' Create CytoscapeJS widget
#'
#' Pass network information to CytoscapeJS widget
#' 
#' @param nodeEntries nodes output from createCytoscapeJsNetwork function
#' @param edgeEntries edges output from createCytoscapeJsNetwork function
#' @param layout the layout algorithm to use for layout. If 'preset', then columns
#'   'x' and 'y' from nodeEntries will be used for position information.
#' @param width width of widget (Default: 100 percent for Shiny apps)
#' @param height height of widget (Default: 400px for Shiny apps)
#' @param showPanzoom whether to show the CytoscapeJS panzoom menu in the upper left corner (Default: TRUE)
#' @param highlightConnectedNodes whether to highlight connected nodes to a clicked node (Default: TRUE)
#' @param boxSelectionEnabled whether to allow users to box select multiple nodes (Default: TRUE)
#'
#' @examples 
#' id <- c("Jerry", "Elaine", "Kramer", "George")
#' name <- id
#' nodeData <- data.frame(id, name, stringsAsFactors=FALSE)
#' 
#' source <- c("Jerry", "Jerry", "Jerry", "Elaine", "Elaine", "Kramer", "Kramer", "Kramer", "George")
#' target <- c("Elaine", "Kramer", "George", "Jerry", "Kramer", "Jerry", "Elaine", "George", "Jerry")
#' edgeData <- data.frame(source, target, stringsAsFactors=FALSE)
#' 
#' network <- createCytoscapeJsNetwork(nodeData, edgeData)
#' rcytoscapejs(network$nodes, network$edges)
#'
#' @import htmlwidgets
#' @seealso \code{\link{createCytoscapeJsNetwork}}
#' @export
rcytoscapejs <- function(nodeEntries, edgeEntries, layout="cose", width=NULL, 
                         height=NULL, showPanzoom=TRUE, highlightConnectedNodes=TRUE, boxSelectionEnabled=TRUE) {
  # forward options using x
  x = list()
  x$nodeEntries <- nodeEntries
  x$edgeEntries <- edgeEntries
  x$layout <- layout
  x$showPanzoom <- showPanzoom
  x$highlightConnectedNodes <- highlightConnectedNodes
  x$boxSelectionEnabled <- boxSelectionEnabled

  # create widget
  htmlwidgets::createWidget(
    name = 'rcytoscapejs',
    x,
    width = width,
    height = height,
    package = 'rcytoscapejs'
  )
}

#' Widget output function for use in Shiny
#'
#' @param outputId a string identifying the Shiny output
#' @param width width of the widget
#' @param height height of the widget
#'
#' @export
rcytoscapejsOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'rcytoscapejs', width, height, package='rcytoscapejs')
}

#' Widget render function for use in Shiny
#' 
#' @param expr An expression that returns an R object that can be used as an argument to cat.
#' @param env	The environment in which to evaluate expr.
#' @param quoted Is expr a quoted expression (with quote())? This is useful if you want to save an expression in a variable.
#'
#' @export
renderRcytoscapejs <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, rcytoscapejsOutput, env, quoted = TRUE)
}
