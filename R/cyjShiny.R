#' @importFrom jsonlite toJSON fromJSON
#' @importFrom htmlwidgets createWidget shinyWidgetOutput shinyRenderWidget
#' @importFrom base64enc base64decode
#' @import shiny
#'
#' @title cyjShiny
#------------------------------------------------------------------------------------------------------------------------
#' cyjShiny
#'
#' @description
#' This widget wraps cytoscape.js, a full-featured Javsscript network library for visualization and analysis.
#'
#' @aliases cyjShiny
#' @rdname cyjShiny
#'
#' @param graph an R graphNEL instance (igraph support coming soon).
#' @param layoutName character one of:"preset", "cose", "cola", "circle", "concentric", "breadthfirst", "grid", "random", "dagre", "cose-bilkent"
#' @param style_file, default NULL, can name a standard javascript cytoscape.js style file
#' @param width integer  initial width of the widget.
#' @param height integer initial height of the widget.
#' @param elementId string the DOM id into which the widget is rendered, default NULL is best.
#'
#' @return a reference to an htmlwidget.
#'
#'
#' @examples
#' \dontrun{
#'   output$cyjShiny <- renderCyjShiny(cyjShiny(graph))
#' }
#'
#' @export

cyjShiny <- function(graph, layoutName, style_file=NULL, width = NULL, height = NULL, elementId = NULL)
{
   stopifnot(layoutName %in% c("preset",
                               "cose",
                               "cola",
                               "circle",
                               "concentric",
                               "breadthfirst",
                               "grid",
                               "random",
                               "dagre",
                               "cose-bilkent"))

   if (is.null(style_file)) {
      style = NULL
   } else {
      if(file.exists(style_file)){
	     jsonText <- toJSON(fromJSON(style_file))   # very strict parser, no unquoted field names
	     style <- list(json=jsonText)
      } else {
              warning(sprintf("cannot read style file: %s, continuing with default", style_file))
              style = NULL
      }
   }

   x <- list(graph=graph, layoutName=layoutName, style=style)

   htmlwidgets::createWidget(
      name = 'cyjShiny',
      x,
      width = width,
      height = height,
      package = 'cyjShiny',
      elementId = elementId,
      sizingPolicy = htmlwidgets::sizingPolicy(browser.fill=TRUE, )
                                    # defaultWidth=500,
                                    # defaultHeight=500,
                                    # viewer.padding=0,
                                    # viewer.suppress=FALSE,
                                    # viewer.paneHeight=500,
                                    # browser.fill=TRUE)
      )

} # cyjShiny constructor
#------------------------------------------------------------------------------------------------------------------------
#' Standard shiny ui rendering construct
#'
#' @param outputId the name of the DOM element to create.
#' @param width integer  optional initial width of the widget.
#' @param height integer optional initial height of the widget.
#'
#' @return a reference to an htmlwidget
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   mainPanel(cyjShinyOutput('cyjShiny'), width=10)
#' }
#'
#' @aliases cyjShinyOutput
#' @rdname cyjShinyOutput
#'
#' @export

cyjShinyOutput <- function(outputId, width = '100%', height = '400')
{
    htmlwidgets::shinyWidgetOutput(outputId, 'cyjShiny', width, height, package = 'cyjShiny')
}
#------------------------------------------------------------------------------------------------------------------------
#' More shiny plumbing -  a cyjShiny wrapper for htmlwidget standard rendering operation
#'
#' @param expr an expression that generates an HTML widget.
#' @param env environment in which to evaluate expr.
#' @param quoted logical specifies whether expr is quoted ("useuful if you want to save an expression in a variable").
#'
#' @return not sure
#'
#' @aliases renderCyjShiny
#' @rdname renderCyjShiny
#'
#' @export

renderCyjShiny <- function(expr, env = parent.frame(), quoted = FALSE)
{
   if (!quoted){
      expr <- substitute(expr)
      } # force quoted

  htmlwidgets::shinyRenderWidget(expr, cyjShinyOutput, env, quoted = TRUE)

}
#------------------------------------------------------------------------------------------------------------------------
#' load a standard cytoscape.js style file
#'
#' @param filename character string, either relative or absolute path.
#'
#' @return nothing
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   loadStyleFile(system.file(package="cyjShiny", "extdata", "yeastGalactoseStyle.js"))
#' }
#'
#' @aliases loadStyleFile
#' @rdname loadStyleFile
#'
#' @export

loadStyleFile <- function(filename)
{
   if(!file.exists(filename)){
      warning(sprintf("cannot read style file: %s", filename))
      return();
      }

   jsonText <- toJSON(fromJSON(filename))   # very strict parser, no unquoted field names
   #lines <- scan(filename, what=character(), strip.white=TRUE, quote="'")
   #jsonText <- paste(lines, collapse=" ")
   message <- list(json=jsonText)
   session <- shiny::getDefaultReactiveDomain()
   session$sendCustomMessage("loadStyle", message)

} # loadStyleFile
#------------------------------------------------------------------------------------------------------------------------
#' Set zoom and center of the graph display so that graph fills the display.
#'
#' @param session a Shiny server session object.
#' @param padding integer, default 50 pixels.
#'
#' @examples
#' \dontrun{
#'   fit(session, 100)
#'}
#'
#' @aliases fit
#' @rdname fit
#'
#' @seealso\code{\link{fitSelected}}
#'
#' @export

fit <- function(session, padding=50)
{
   session$sendCustomMessage("fit", list(padding=padding))

} # fitSelected
#------------------------------------------------------------------------------------------------------------------------
#' Set zoom and center of the graph display so that the currently selected nodes fill the display
#'
#' @param session  a Shiny server session object.
#' @param padding integer, default 50 pixels.
#'
#' @examples
#' \dontrun{
#'   fitSelected(session, 100)
#' }
#'
#' @aliases fitSelected
#' @rdname fitSelected
#'
#' @seealso\code{\link{fit}}
#'
#' @export

fitSelected <- function(session, padding=50)
{
   session$sendCustomMessage("fitSelected", list(padding=padding))

} # fitSelected
#------------------------------------------------------------------------------------------------------------------------
#' getSelectedNodes
#'
#' \code{getSelectedNodes} get the selected nodes
#'
#' @rdname getSelectedNodes
#' @aliases getSelectedNodes
#'
#' @param session a Shiny server session object.
#'
#' @return a data.frame with (at least) an id column
#'
#' @export
#'

getSelectedNodes <- function(session)
{
   session$sendCustomMessage("getSelectedNodes", message=list())

} # getSelectedNodes
#----------------------------------------------------------------------------------------------------
#' Assign the supplied node attribute values to the graph structure contained in the browser.
#'
#' @param session a Shiny Server session object.
#' @param attributeName character string, the attribute to update.
#' @param nodes a character vector the names of the nodes whose attributes are updated.
#' @param values a character, logical or numeric vector, the new values.
#'
#' @examples
#' \dontrun{
#'   setNodeAttributes(session,
#'                     attributeName=attribute,
#'                     nodes=yeastGalactodeNodeIDs,
#'                     values=expression.vector)
#' }
#'
#' @aliases setNodeAttributes
#' @rdname setNodeAttributes
#'
#' @export

setNodeAttributes <- function(session, attributeName, nodes, values)
{
   session$sendCustomMessage(type="setNodeAttributes",
                             message=list(attribute=attributeName,
                                          nodes=nodes,
                                          values=values))
} # setNodeAttributes
#------------------------------------------------------------------------------------------------------------------------
#' Assign the supplied edge attribute values to the graph structure contained in the browser.
#'
#' @param session a Shiny Server session object.
#' @param attributeName character string, the attribute to update.
#' @param sourceNodes a character vector, the names of the source nodes of the edges
#' @param targetNodes a character vector, the names of the target nodes of the edgees
#' @param interactions a character vector, further identifying the specific edge whose attributes are updated.
#' @param values a character, logical or numeric vector, the new values.
#'
#' @examples
#' \dontrun{
#'   setEdgeAttributes(session,
#'                     attributeName="score",
#'                     sourceNodes=c("A", "B", "C"),
#'                     targetNodes=c("D", "E", "A"),
#'                     interactions=c("promotes", "promotes", "inhibits"),
#'                     values=new.scores)
#' }
#'
#' @aliases setEdgeAttributes
#' @rdname setEdgeAttributes
#'
#' @export

setEdgeAttributes <- function(session, attributeName, sourceNodes, targetNodes, interactions, values)
{
   session$sendCustomMessage(type="setEdgeAttributes",
                             message=list(attributeName=attributeName,
                                          sourceNodes=sourceNodes,
                                          targetNodes=targetNodes,
                                          interactions=interactions,
                                          values=values))
} # setEdgeAttributes
#------------------------------------------------------------------------------------------------------------------------
#' Layout the current graph using the specified strategy.
#'
#' @param session a Shiny Server session object.
#' @param strategy a character string, one of cola, cose, circle, concentric, grid, breadthfirst, random, dagre, cose-bilkent.
#'
#' @examples
#' \dontrun{
#'   doLayout(session, "cola")
#' }
#' @aliases doLayout
#' @rdname doLayout
#'
#' @export

doLayout <- function(session, strategy)
{
   stopifnot(strategy %in% c("cola", "cose", "circle", "concentric", "grid", "breadthfirst", "random",
                             "dagre", "cose-bilkent"))

   session$sendCustomMessage(type="doLayout", message=list(strategy=strategy))

} # doLayout
#------------------------------------------------------------------------------------------------------------------------
#' get node positions
#'
#' @param session a Shiny Server session object.
#'
#' @aliases getNodePositions
#' @rdname getNodePositions
#'
#' @export

getNodePositions <- function(session)
{
   x <- session$sendCustomMessage(type="getNodePositions", message=list())

} # getNodePositions
#------------------------------------------------------------------------------------------------------------------------
#' set node positions from the supplied data.frame
#'
#' @param session a Shiny Server session object.
#' @param tbl.positions a data.frame with three columns: id, x, y
#'
#' @aliases setNodePositions
#' @rdname setNodePositions
#'
#' @export

setNodePositions <- function(session, tbl.positions)
{
   stopifnot(colnames(tbl.positions) == c("id", "x", "y"))

   tbl.json <- toJSON(tbl.positions) # force a json representation which is an array of {id,x,y{ objects
   session$sendCustomMessage(type="setNodePositions", message=list(tbl=tbl.json))

} # setNodePositions
#------------------------------------------------------------------------------------------------------------------------
#' remove the current graph
#'
#' @param session a Shiny Server session object.
#'
#' @examples
#' \dontrun{
#'   removeGraph(session)
#' }
#' @aliases removeGraph
#' @rdname removeGraph
#'
#' @export

removeGraph <- function(session)
{
   message(sprintf("entering cyjShiny::removeGraph"))
   session$sendCustomMessage(type="removeGraph", message=list())

} # removeGraph
#------------------------------------------------------------------------------------------------------------------------
#' addGraphFromDataFrame
#'
#' @param session a Shiny Server session object.
#' @param tbl.edges a data.frame with source, traget, interaction columns (and option other attributes)
#' @param tbl.nodes (optional; nodes can be deduced from tbl.edges) a data.frame with nodes and their attributes
#'
#' @examples
#' \dontrun{
#'   addGraphFromDataFrame (session)
#' }
#'
#' @aliases addGraphFromDataFrame
#' @rdname addGraphFromDataFrame
#'
#' @export

addGraphFromDataFrame <- function(session, tbl.edges, tbl.nodes=NULL)
{
   illegal.tbl <- ncol(tbl.edges) < 3
   illegal.colnames <- !(all(colnames(tbl.edges)[1:3] == c("source", "target", "interaction")))

   if(illegal.tbl | illegal.colnames){
      msg <- sprintf("required colnames for tbl.edges: 'source'  'target'  'interaction'")
      cat(msg)
      return()
      }

   g.json <- dataFramesToJSON(tbl.edges, tbl.nodes)
   session$sendCustomMessage(type="addGraph", message=list(graph=g.json))

} # addGraphFromDataFrame
#------------------------------------------------------------------------------------------------------------------------
#' addGraphFromJsonFile
#'
#' @param session a Shiny Server session object.
#' @param jsonFilename of a text file with JSON representation of a cytoscape.js graph
#'
#' @examples
#' \dontrun{
#'   addGraphFromJsonFile (session)
#' }
#' @aliases addGraphFromJsonFile
#' @rdname addGraphFromJsonFile
#'
#' @export
#'
addGraphFromJsonFile <- function(session, jsonFilename)
{
   g.json <- readLines(jsonFilename)
   session$sendCustomMessage(type="addGraph", message=list(graph=g.json))

} # addGraphFromJSON
#------------------------------------------------------------------------------------------------------------------------
#' selectNodes
#'
#' @param session a Shiny Server session object.
#' @param nodeNames character, a list of node IDs
#'
#' @aliases selectNodes
#' @rdname selectNodes
#'
#' @export
#'
selectNodes <- function(session, nodeNames)
{
   session$sendCustomMessage(type="selectNodes", message=list(nodeNames))

} # selectNodes
#------------------------------------------------------------------------------------------------------------------------
#' selectFirstNeighbors of the currently selected nodes
#'
#' @param session a Shiny Server session object.
#'
#' @aliases selectFirstNeighbors
#' @rdname  selectFirstNeighbors
#'
#' @export
#'
selectFirstNeighbors <- function(session)
{
   session$sendCustomMessage(type="sfn", message=list())

} # selectFirstNeighbors
#------------------------------------------------------------------------------------------------------------------------
#' clearSelection all node and edge selections removed
#'
#' @param session a Shiny Server session object.
#'
#' @aliases clearSelection
#' @rdname clearSelection
#'
#' @export
#'
clearSelection <- function(session)
{
   session$sendCustomMessage(type="clearSelection", message=list())

} # clearSelection
#------------------------------------------------------------------------------------------------------------------------
#' save a png rendering of the current network view to the specified filename
#'
#' @param session a Shiny Server session object.
#' @param filename a character string
#'
#' @aliases savePNGtoFile
#' @rdname savePNGtoFile
#'
#' @export
#'
savePNGtoFile <- function(session, filename)
{
   session$sendCustomMessage(type="savePNGtoFile", message=list(filename))

} # clearSelection
#------------------------------------------------------------------------------------------------------------------------
