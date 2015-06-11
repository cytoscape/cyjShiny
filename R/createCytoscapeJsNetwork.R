#' Generate a CytoscapeJS compatible network
#'
#' @param nodeData a data.frame with at least two columns: id and name; Any additional 
#'   columns from nodeData will be passed to CytoscapeJS. If 'x' and 'y' columns are 
#'   specified and the layout in rcytoscapejs function is set 
#'   to 'preset' then the user-specified locations will be used. 
#' @param edgeData a data.frame with at least two columns: source and target
#' @param nodeColor a hex color for nodes (default: #666666)
#' @param nodeShape a shape for nodes (default: ellipse)
#' @param nodeHeight node height (default: 30)
#' @param nodeWidth node width (default: 30)
#' @param nodeLabelColor node label color (default: #FFFFFF)
#' @param edgeColor a hex color for edges (default: #666666)
#' @param edgeSourceShape a shape for arrow sources (default: none)
#' @param edgeTargetShape a shape for arrow targets (default: triangle)
#' @param nodeHref a link associated with the node (appears in a tooltip)
#'
#' @return a list with two entries:
#' 
#' \itemize{
#'   \item nodes a JSON string with node information compatible with CytoscapeJS
#'   \item edges a JSON string with edge information compatible with CytoscapeJS
#' }
#' 
#' If required columns (see parameters) are not provided, an error will be thrown
#' 
#' See http://cytoscape.github.io/cytoscape.js/ for shape details
#'
#' @seealso \code{\link{rcytoscapejs}}
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
#'
#' @export
createCytoscapeJsNetwork <- function(nodeData, edgeData,
                                     nodeColor="#888888", nodeShape="ellipse",
                                     nodeHeight="70", nodeWidth="70", nodeLabelColor="#FFFFFF",
                                     edgeColor="#888888", edgeSourceShape="none",
                                     edgeTargetShape="triangle", nodeHref="") {

    # There must be nodes and nodeData must have at least id and name columns
    if(nrow(nodeData) == 0 || !(all(c("id", "name") %in% names(nodeData)))) {
        stop("ERROR: nodeData must have 'id' and 'name' columns")
    }

    # There must be edges and edgeData must have at least source and target columns
    if(nrow(edgeData) == 0 || !(all(c("source", "target") %in% names(edgeData)))) {
      stop("ERROR: edgeData must have 'source' and 'target' columns")
    }

    # NODES
    ## Add color/shape columns if not present
    if(!("color" %in% colnames(nodeData))) {
        nodeData$color <- rep(nodeColor, nrow(nodeData))
    }

    if(!("shape" %in% colnames(nodeData))) {
        nodeData$shape <- rep(nodeShape, nrow(nodeData))
    }

    if(!("href" %in% colnames(nodeData))) {
        nodeData$href <- rep(nodeHref, nrow(nodeData))
    }

    if(!("height" %in% colnames(nodeData))) {
      nodeData$height <- rep(nodeHeight, nrow(nodeData))
    }
  
    if(!("width" %in% colnames(nodeData))) {
      nodeData$width <- rep(nodeWidth, nrow(nodeData))
    }
  
    if(!("nodeLabelColor" %in% colnames(nodeData))) {
      nodeData$nodeLabelColor <- rep(nodeLabelColor, nrow(nodeData))
    }
  
    rownames(nodeData) <- NULL
    nodeEntries <- apply(nodeData,1,function(x){
        list(data=as.list(x))
    })

    # EDGES
    ## Add color/shape columns if not present
    if(!("color" %in% colnames(edgeData))) {
        edgeData$color <- rep(edgeColor, nrow(edgeData))
    }

    if(!("sourceShape" %in% colnames(edgeData))) {
        edgeData$edgeSourceShape <- rep(edgeSourceShape, nrow(edgeData))
    }

    if(!("targetShape" %in% colnames(edgeData))) {
        edgeData$edgeTargetShape <- rep(edgeTargetShape, nrow(edgeData))
    }

    rownames(edgeData) <- NULL
    edgeEntries <- apply(edgeData,1,function(x){
        list(data=as.list(x))
    })

    network <- list(nodes=nodeEntries, edges=edgeEntries)

    return(network)
}
