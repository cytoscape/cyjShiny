#' Convert R graphNEL object to cytoscape.js JSON.
#'
#' @import graph
#'
#'
#' @param g  a graphNEL
#'
#' @examples
#' \dontrun{
#'   g.json <- graphNELtoJSON(graphNEL())
#' }
#'
#' @aliases graphNELtoJSON
#' @rdname graphNELtoJSON
#'
#' @export

graphNELtoJSON <- function(g) #Copied from RCyjs/R/utils.R
{
   if(length(nodes(g)) == 0)
      return ("{}")

       # allocate more character vectors that we could ever need; unused are deleted at conclusion

    vector.count <- 10 * (length(edgeNames(g)) + length (nodes(g)))
    vec <- vector(mode="character", length=vector.count)
    i <- 1;

    vec[i] <- '{"elements": {"nodes": ['; i <- i + 1;
    nodes <- nodes(g)
    edgeNames <- edgeNames(g)
    edges <- strsplit(edgeNames, "~")  # a list of pairs
    edgeNames <- sub("~", "->", edgeNames)
    names(edges) <- edgeNames

    noa.names <- names(graph::nodeDataDefaults(g))
    eda.names <- names(graph::edgeDataDefaults(g))
    nodeCount <- length(nodes)
    edgeCount <- length(edgeNames)

    for(n in 1:nodeCount){
       node <- nodes[n]
       vec[i] <- '{"data": '; i <- i + 1
       nodeList <- list(id = node)
       this.nodes.data <- graph::nodeData(g, node)[[1]]
       if(length(this.nodes.data) > 0)
          nodeList <- c(nodeList, this.nodes.data)
       nodeList.json <- toJSON(nodeList, auto_unbox=TRUE)
       vec[i] <- nodeList.json; i <- i + 1
       if(all(c("xPos", "yPos") %in% names(graph::nodeDataDefaults(g)))){
          position.markup <- sprintf(', "position": {"x": %f, "y": %f}',
                                     graph::nodeData(g, node, "xPos")[[1]],
                                     graph::nodeData(g, node, "yPos")[[1]])
          vec[i] <- position.markup
          i <- i + 1
          }
        if(n != nodeCount){
           vec [i] <- "},"; i <- i + 1 # sprintf("%s},", x)  # another node coming, add a comma
           }
       } # for n

    vec [i] <- "}]"; i <- i + 1  # close off the last node, the node array ], the nodes element }

    if(edgeCount > 0){
       vec[i] <- ', "edges": [' ; i <- i + 1
       for(e in seq_len(edgeCount)) {
          vec[i] <- '{"data": '; i <- i + 1
          edgeName <- edgeNames[e]
          edge <- edges[[e]]
          sourceNode <- edge[[1]]
          targetNode <- edge[[2]]
          edgeList <- list(id=edgeName, source=sourceNode, target=targetNode)
          this.edges.data <- graph::edgeData(g, sourceNode, targetNode)[[1]]
          if(length(this.edges.data) > 0)
             edgeList <- c(edgeList, this.edges.data)
          edgeList.json <- toJSON(edgeList, auto_unbox=TRUE)
          vec[i] <- edgeList.json; i <- i + 1
          if(e != edgeCount){          # add a comma, ready for the next edge element
             vec [i] <- '},'; i <- i + 1
             }
          } # for e
      vec [i] <- "}]"; i <- i + 1
      } # if edgeCount > 0

   vec [i] <- "}"  # close the edges object
   i <- i + 1;
   vec [i] <- "}"  # close the elements object
   vec.trimmed <- vec [which(vec != "")]
   #printf("%d strings used in constructing json", length(vec.trimmed))
   paste0(vec.trimmed, collapse=" ")

} # graphNELtoJSON
#----------------------------------------------------------------------------------------------------------
#' Create a cytoscape.js JSON graph from one or two data.frames.
#'
#' @param tbl.edges data.frame, with source, target and interaction columns, others option for edge attributes
#' @param tbl.nodes data.frame, options, useful for orphan nodes, and necessary for adding node attributes
#'

#' @aliases dataFramesToJSON
#' @rdname dataFramesToJSON
#'
#' @export

dataFramesToJSON <- function(tbl.edges, tbl.nodes=NULL)
{
      # catch any factor columns - they only cause trouble
   stopifnot(!grepl("factor", as.character(lapply(tbl.edges, class))))
   stopifnot(all(c("source", "target") %in% colnames(tbl.edges)))
   stopifnot("interaction" %in% colnames(tbl.edges))

   nodes.implied.by.edgeData <- sort(unique(c(tbl.edges$source, tbl.edges$target)))

   if(is.null(tbl.nodes)){ # derive one from tbl.edges, for consistent processing below
      node.count <- length(nodes.implied.by.edgeData)
      tbl.nodes <- data.frame(id=nodes.implied.by.edgeData,
                              type=rep("unspecified", node.count),
                              stringsAsFactors=FALSE)
      } # no tbl.nodes supplied

   nodes <- sort(unique(c(tbl.edges$source, tbl.edges$target, tbl.nodes$id)))

   edgeCount <- nrow(tbl.edges)
   vector.count <- 10 * (edgeCount + length(nodes))
   vec <- vector(mode="character", length=vector.count)
   i <- 1;

   vec[i] <- '{"elements": {"nodes": ['; i <- i + 1;


   noa.names <- colnames(tbl.nodes)[-1]
   eda.names <- colnames(tbl.edges)[-(1:2)]
   nodeCount <- length(nodes)

   for(n in 1:nodeCount){
      node <- nodes[n]
      vec[i] <- '{"data": '; i <- i + 1
      nodeList <- list(id=node)
      if(ncol(tbl.nodes) > 1)
         nodeList <- c(nodeList, as.list(tbl.nodes[n, -1, drop=FALSE]))
      nodeList.json <- toJSON(nodeList, auto_unbox=TRUE)
      vec[i] <- nodeList.json; i <- i + 1
      if(n != nodeCount){
          vec [i] <- "},"; i <- i + 1 # sprintf("%s},", x)  # another node coming, add a comma
          }
       } # for n

    vec [i] <- "}]"; i <- i + 1  # close off the last node, the node array ], the nodes element }

    if(edgeCount > 0){
       vec[i] <- ', "edges": [' ; i <- i + 1
       for(e in seq_len(edgeCount)) {
          vec[i] <- '{"data": '; i <- i + 1
          sourceNode <- tbl.edges[e, "source"]
          targetNode <- tbl.edges[e, "target"]
          interaction <- tbl.edges[e, "interaction"]
          edgeName <- sprintf("%s-(%s)-%s", sourceNode, interaction, targetNode)

          edgeList <- list(id=edgeName, source=sourceNode, target=targetNode, interaction=interaction)
          if(ncol(tbl.edges) > 3)
             edgeList <- c(edgeList, as.list(tbl.edges[e, -(1:3), drop=FALSE]))
          edgeList.json <- toJSON(edgeList, auto_unbox=TRUE)
          vec[i] <- edgeList.json; i <- i + 1
          if(e != edgeCount){          # add a comma, ready for the next edge element
             vec [i] <- '},'; i <- i + 1
             }
          } # for e
      vec [i] <- "}]"; i <- i + 1
      } # if edgeCount > 0

   vec [i] <- "}"  # close the edges object
   i <- i + 1;
   vec [i] <- "}"  # close the elements object
   vec.trimmed <- vec [which(vec != "")]
   paste0(vec.trimmed, collapse=" ")

} # dataFramesToJSON
#----------------------------------------------------------------------------------------------------------
