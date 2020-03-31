#----------------------------------------------------------------------------------------------------
library(RUnit)
library(cyjShiny)
#------------------------------------------------------------------------------------------------------------------------
printf <- function(...) print(noquote(sprintf(...)))
#------------------------------------------------------------------------------------------------------------------------
# use ~/github/projects/examples/cyjsMinimal/cyjs.html to test out json strings produced here
#------------------------------------------------------------------------------------------------------------------------
if(!exists("g.big")){
   g.big <- get(load(system.file(package="cyjShiny", "extdata",
                                 "graph.1669nodes_3260edges_challenge_for_converting_to_json.RData")))
   }

if(!exists("g.small")){
   g.small <- get(load(system.file(package="cyjShiny", "extdata",  "graph.11nodes.14edges.RData")))
   }


#------------------------------------------------------------------------------------------------------------------------
runTests <- function(display=FALSE)
{
   test_1669_3260(display)
   test_2_nodes_2_edges_no_attributes(display)
   test_20_nodes_20_edges_no_attributes(display)
   test_200_nodes_200_edges_no_attributes(display)
   test_2000_nodes_2000_edges_no_attributes(display)
   test_1_node(display)
   test_3_nodes_with_position(display)
   test_2_nodes(display)
   test_2_nodes_1_edge(display)
   test_1_node_2_attributes(display)
   test_2_nodes_1_edge_2_edgeAttribute(display)
   test_smallGraphWithAttributes(display)
   test_dataFramesToJSON_edgeTableOnly_noExtraAttributes(display)
   test_dataFramesToJSON_edgeTableOnly_orhpanNodeInNodeTable(display)
   test_dataFramesToJSON_edgeTableOnly_addEdgeAttributes(display)
   test_dataFramesToJSON_explicitNodePositions(display)
   test_readAndStandardizeJSONStyleFile()
   test_readAndStandardizeJSONNetworkFile()
   test_unorderedNodeIDs()

} # runTests
#------------------------------------------------------------------------------------------------------------------------
runDataFrameTests <- function()
{
   test_dataFramesToJSON_edgeTableOnly_noExtraAttributes(display=FALSE)
   test_dataFramesToJSON_edgeTableOnly_orhpanNodeInNodeTable(display=FALSE)
   test_dataFramesToJSON_edgeTableOnly_addEdgeAttributes(display=FALSE)

} # runDataFrameTests
#------------------------------------------------------------------------------------------------------------------------
createTestGraph <- function(nodeCount, edgeCount)
{
   elementCount <- nodeCount^2;
   vec <- rep(0, elementCount)

   set.seed(13);
   vec[sample(1:elementCount, edgeCount)] <- 1
   mtx <- matrix(vec, nrow=nodeCount)

   gam <- graphAM(adjMat=mtx, edgemode="directed")

   as(gam, "graphNEL")

} # createTestGraph
#----------------------------------------------------------------------------------------------------
test_1669_3260 <- function(display=FALSE)
{
   message(sprintf("--- test_1669_3260"))
   g.json <- graphNELtoJSON(g.small)

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display


   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   checkEquals(lapply(g2, dim), list(nodes=c(11, 27), edges=c(14,4)))

   system.time(  # < 14 seconds elapsed: 1669 nodes, 3260 edges
      g.json <- graphNELtoJSON(g.big)
      )

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   checkEquals(lapply(g2, dim), list(nodes=c(1669, 83), edges=c(3260, 4)))

 } # test_1669_3260
#------------------------------------------------------------------------------------------------------------------------
test_2_nodes_2_edges_no_attributes <- function(display=FALSE)
{
   message(sprintf("--- test_2_nodes_2_edges_no_attributes"))

   g <- createTestGraph(2, 2)
   g.json <- graphNELtoJSON(g)

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   tbl.nodes <- g2$nodes
   checkEquals(tbl.nodes$data.id, nodes(g))
   tbl.edges <- g2$edges
   checkEquals(dim(tbl.edges), c(2, 3))

 } # test_2_nodes_2_edges_no_attributes
#------------------------------------------------------------------------------------------------------------------------
test_20_nodes_20_edges_no_attributes <- function(display=FALSE)
{
   message(sprintf("--- test_20_nodes_20_edges_no_attributes"))

   g <- createTestGraph(20, 20)
   g.json <- graphNELtoJSON(g)

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   tbl.nodes <- g2$nodes
   checkEquals(tbl.nodes$data.id, nodes(g))
   tbl.edges <- g2$edges
   checkEquals(dim(tbl.edges), c(20, 3))

 } # test_2_nodes_2_edges_no_attributes
#------------------------------------------------------------------------------------------------------------------------
test_200_nodes_200_edges_no_attributes <- function(display=FALSE)
{
   message(sprintf("--- test_200_nodes_200_edges_no_attributes"))

   g <- createTestGraph(200, 200)
   g.json <- graphNELtoJSON(g)

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   tbl.nodes <- g2$nodes
   checkEquals(tbl.nodes$data.id, nodes(g))
   tbl.edges <- g2$edges
   checkEquals(dim(tbl.edges), c(199, 3))

 } # test_200_nodes_200_edges_no_attributes
#------------------------------------------------------------------------------------------------------------------------
test_2000_nodes_2000_edges_no_attributes <- function(display=FALSE)
{
   message(sprintf("--- test_2000_nodes_2000_edges_no_attributes"))

   print(system.time({   # 4 seconds
      g <- createTestGraph(2000, 2000)
      g.json <- graphNELtoJSON(g)
      }))

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   tbl.nodes <- g2$nodes
   checkEquals(tbl.nodes$data.id, nodes(g))
   tbl.edges <- g2$edges
   checkEquals(dim(tbl.edges), c(2000, 3))

 } # test_2000_nodes_2000_edges_no_attributes
#------------------------------------------------------------------------------------------------------------------------
test_1_node <- function(display=FALSE)
{
   message(sprintf("--- test_1_node"))
   g <- graphNEL(nodes="A", edgemode="directed")
   g.json <- graphNELtoJSON(g)

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   tbl.nodes <- g2$nodes
   checkEquals(tbl.nodes$data.id, nodes(g))

} # test_1_node
#------------------------------------------------------------------------------------------------------------------------
test_3_nodes_with_position <- function(display=FALSE)
{
   message(sprintf("--- test_3_nodes_with_position"))

     #-------------------------------------------------------------------------------------
     # first test the old-style (pre-2020) position attributes, which are still supported:
     #-------------------------------------------------------------------------------------

   g <- graphNEL(nodes=c("A", "B", "C"), edgemode="directed")
   nodeDataDefaults(g, "xPos") <- 0
   nodeDataDefaults(g, "yPos") <- 0
   nodeData(g, n=c("A", "B", "C"), attr="xPos") <- c(100,200,300)
   nodeData(g, n=c("A", "B", "C"), "yPos") <- c(100,200,300)

   g.json <- graphNELtoJSON(g)

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

     #--------------------------------------------------------
     # now test the new, more simply named position attributes
     #--------------------------------------------------------

   g1 <- graphNEL(nodes=c("A", "B", "C"), edgemode="directed")
   nodeDataDefaults(g1, "x") <- 0
   nodeDataDefaults(g1, "y") <- 0
   nodeData(g1, n=c("A", "B", "C"), attr="x") <- c(100, 200, 300)
   nodeData(g1, n=c("A", "B", "C"), "y") <- c(300, 200, 100)

   g1.json <- graphNELtoJSON(g1)

   if(display){
      writeLines(sprintf("network = %s", g1.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

      #--------------------------------------------------------------
      # g1 has node positions in the "x" and "y" node attributes
      # graphNELtoJSON(g1) copies them into a position data structure
      # here we test that the same values are place in each
      #--------------------------------------------------------------

   g2 <- fromJSON(g1.json, flatten=TRUE)$elements
   tbl.nodes <- g2$nodes
   checkEquals(tbl.nodes$data.id, nodes(g))
   checkEqualsNumeric(tbl.nodes$data.x,  c(100, 200, 300))
   checkEquals(tbl.nodes$position.x,     c(100, 200, 300))
   checkEqualsNumeric(tbl.nodes$data.y,  c(300, 200, 100))
   checkEquals(tbl.nodes$position.y,     c(300, 200, 100))

} # test_3_nodes_with_position
#------------------------------------------------------------------------------------------------------------------------
test_2_nodes <- function(display=FALSE)
{
   message(sprintf("--- test_2_nodes"))

   g <- graphNEL(nodes=c("A", "B"), edgemode="directed")
   g.json <- graphNELtoJSON(g)

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   tbl.nodes <- g2$nodes
   checkEquals(tbl.nodes$data.id, nodes(g))

} # test_2_nodes
#------------------------------------------------------------------------------------------------------------------------
test_2_nodes_1_edge <- function(display=FALSE)
{
   message(sprintf("--- test_2_nodes_1_edge"))

   g <- graphNEL(nodes=c("X", "Y"), edgemode="directed")
   g <- addEdge("X", "Y", g);
   g.json <- graphNELtoJSON(g)

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

      #  flatten: automatically ‘flatten’ nested data frames into a single non-nested data frame
   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   checkEquals(names(g2), c("nodes", "edges"))
   tbl.nodes <- g2$nodes
   checkEquals(dim(tbl.nodes), c(2,1))
   checkEquals(tbl.nodes$data.id, c("X", "Y"))

   tbl.edges <- g2$edges
   checkEquals(dim(tbl.edges), c(1,3))
   checkEquals(tbl.edges$data.id, "X->Y")

} # test_2_nodes_1_edge
#------------------------------------------------------------------------------------------------------------------------
test_1_node_2_attributes <- function(display=FALSE)
{
   message(sprintf("--- test_1_node_2_attributse"))

   g <- graphNEL(nodes="A", edgemode="directed")
   nodeDataDefaults(g, "size") <- 0
   nodeData(g, "A", "size") <- 99

   nodeDataDefaults(g, "label") <- ""
   nodeData(g, "A", "label") <- "bigA"

   g.json <- graphNELtoJSON(g)

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   tbl.nodes <- g2$nodes
   checkEquals(tbl.nodes$data.id, nodes(g))
   checkEquals(tbl.nodes$data.size, 99)
   checkEquals(tbl.nodes$data.label, "bigA")

} # test_1_node_2_attributes
#------------------------------------------------------------------------------------------------------------------------
test_2_nodes_1_edge_2_edgeAttribute <- function(display=FALSE)
{
   message(sprintf("--- test_2_nodes_2_edgeAttributes"))

   g <- graphNEL(nodes=c("X", "Y"), edgemode="directed")
   g <- addEdge("X", "Y", g);
   edgeDataDefaults(g, "weight") <- 0
   edgeDataDefaults(g, "edgeType") <- "generic"
   edgeData(g, "X", "Y", "weight") <- 1.234
   edgeData(g, "X", "Y", "edgeType") <- "regulates"

   g.json <- graphNELtoJSON(g)

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

      #  flatten: automatically ‘flatten’ nested data frames into a single non-nested data frame
   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   checkEquals(names(g2), c("nodes", "edges"))
   tbl.nodes <- g2$nodes
   checkEquals(dim(tbl.nodes), c(2,1))
   checkEquals(tbl.nodes$data.id, c("X", "Y"))

   tbl.edges <- g2$edges
   checkEquals(dim(tbl.edges), c(1,5))
   checkEquals(tbl.edges$data.id, "X->Y")
   checkEquals(tbl.edges$data.source, "X")
   checkEquals(tbl.edges$data.target, "Y")
   checkEquals(tbl.edges$data.weight, 1.234)
   checkEquals(tbl.edges$data.edgeType, "regulates")

} # test_2_nodes_1_edge
#------------------------------------------------------------------------------------------------------------------------
test_smallGraphWithAttributes <- function(display=FALSE)
{
   message(sprintf("--- test_smallGraphWithAttributes"))
   g <- simpleDemoGraph()
   g.json <- graphNELtoJSON(g)

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

   g2 <- fromJSON(g.json, flatten=TRUE)$elements
   checkEquals(names(g2), c("nodes", "edges"))
   tbl.nodes <- g2$nodes
   tbl.edges <- g2$edges

   checkEquals(dim(tbl.nodes), c(3, 5))
   checkEquals(colnames(tbl.nodes),
               c("data.id", "data.type", "data.lfc", "data.label", "data.count"))
   checkEquals(dim(tbl.edges), c(3, 6))
   checkEquals(colnames(tbl.edges), c("data.id", "data.source", "data.target", "data.edgeType", "data.score", "data.misc"))

} # test_smallGraphWithAttributes
#------------------------------------------------------------------------------------------------------------------------
simpleDemoGraph = function ()
{
  g = new ('graphNEL', edgemode='directed')

  nodeDataDefaults(g, attr='type') <- 'undefined'
  nodeDataDefaults(g, attr='lfc') <-  1.0
  nodeDataDefaults(g, attr='label') <- 'default node label'
  nodeDataDefaults(g, attr='count') <-  0

  edgeDataDefaults(g, attr='edgeType') <- 'undefined'
  edgeDataDefaults(g, attr='score') <-  0.0
  edgeDataDefaults(g, attr= 'misc') <- "default misc"

  g = graph::addNode ('A', g)
  g = graph::addNode ('B', g)
  g = graph::addNode ('C', g)
  nodeData (g, 'A', 'type') = 'kinase'
  nodeData (g, 'B', 'type') = 'transcription factor'
  nodeData (g, 'C', 'type') = 'glycoprotein'

  nodeData (g, 'A', 'lfc') = -3.0
  nodeData (g, 'B', 'lfc') = 0.0
  nodeData (g, 'C', 'lfc') = 3.0

  nodeData (g, 'A', 'count') = 2
  nodeData (g, 'B', 'count') = 30
  nodeData (g, 'C', 'count') = 100

  nodeData (g, 'A', 'label') = 'Gene A'
  nodeData (g, 'B', 'label') = 'Gene B'
  nodeData (g, 'C', 'label') = 'Gene C'

  g = graph::addEdge ('A', 'B', g)
  g = graph::addEdge ('B', 'C', g)
  g = graph::addEdge ('C', 'A', g)

  edgeData (g, 'A', 'B', 'edgeType') = 'phosphorylates'
  edgeData (g, 'B', 'C', 'edgeType') = 'synthetic lethal'

  edgeData (g, 'A', 'B', 'score') =  35.0
  edgeData (g, 'B', 'C', 'score') =  -12

  g

} # simpleDemoGraph
#----------------------------------------------------------------------------------------------------
test_dataFramesToJSON_edgeTableOnly_noExtraAttributes <- function(display)
{
   message(sprintf("--- test_dataFramesToJSON_edgeTableOnly_noExtraAttributes"))

   tbl.edges <- data.frame(source=c("A"),
                           target=c("B"),
                           interaction=c("eats"),
                           stringsAsFactors=FALSE)

   g.json <- dataFramesToJSON(tbl.edges)
   x <- fromJSON(g.json)$elements
   checkEquals(names(x), c("nodes", "edges"))

   tbl.nodes <- x$nodes$data
   checkEquals(dim(tbl.nodes), c(2, 2))
   checkEquals(tbl.nodes$id, c("A", "B"))

   tbl.edges <- x$edges$data
   checkEquals(dim(tbl.edges), c(1, 4))
   checkEquals(colnames(tbl.edges), c("id", "source", "target", "interaction"))
   checkEquals(as.character(tbl.edges[1,]), c("A-(eats)-B", "A", "B", "eats"))

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display


} # test_dataFramesToJSON
#----------------------------------------------------------------------------------------------------
test_dataFramesToJSON_edgeTableOnly_orhpanNodeInNodeTable <- function(display)
{
   message(sprintf("--- test_dataFramesToJSON_edgeTableOnly_orhpanNodeInNodeTable"))

   tbl.edges <- data.frame(source=c("A"),
                           target=c("B"),
                           interaction=c("eats"),
                           stringsAsFactors=FALSE)

   tbl.nodes <- data.frame(id=c("A", "B", "C"),
                           type=c("animal", "vegetable", "mineral"),
                           age=c("recent", "old", "ancient"),
                           stringsAsFactors=FALSE)

   g.json <- dataFramesToJSON(tbl.edges, tbl.nodes)
   x <- fromJSON(g.json)$elements
   checkEquals(names(x), c("nodes", "edges"))

   tbl.nodes <- x$nodes$data
   checkEquals(dim(tbl.nodes), c(3, 3))
   checkEquals(tbl.nodes$id, c("A", "B", "C"))

   tbl.edges <- x$edges$data
   checkEquals(dim(tbl.edges), c(1, 4))
   checkEquals(colnames(tbl.edges), c("id", "source", "target", "interaction"))
   checkEquals(as.character(tbl.edges[1,]), c("A-(eats)-B", "A", "B", "eats"))

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

}  # test_dataFramesToJSON_edgeTableOnly_orhpanNodeInNodeTable
#----------------------------------------------------------------------------------------------------
test_dataFramesToJSON_edgeTableOnly_addEdgeAttributes <- function(display)
{
   message(sprintf("--- test_dataFramesToJSON_edgeTableOnly_orhpanNodeInNodeTable"))

   tbl.edges <- data.frame(source=c("A"),
                           target=c("B"),
                           interaction=c("eats"),
                           duration="long",
                           intensity=3.2,
                           stringsAsFactors=FALSE)

   g.json <- dataFramesToJSON(tbl.edges)
   x <- fromJSON(g.json)$elements
   checkEquals(names(x), c("nodes", "edges"))

   tbl.nodes <- x$nodes$data
   checkEquals(dim(tbl.nodes), c(2, 2))
   checkEquals(tbl.nodes$id, c("A", "B"))

   tbl.edges <- x$edges$data
   checkEquals(dim(tbl.edges), c(1, 6))
   checkEquals(colnames(tbl.edges), c("id", "source", "target", "interaction", "duration", "intensity"))
   checkEquals(tbl.edges[1, "id"], "A-(eats)-B")
   checkEquals(tbl.edges[1, "source"], "A")
   checkEquals(tbl.edges[1, "target"], "B")
   checkEquals(tbl.edges[1, "duration"], "long")
   checkEquals(tbl.edges[1, "intensity"], 3.2)
   checkEquals(tbl.edges[1, "interaction"], "eats")

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

}  # test_dataFramesToJSON_edgeTableOnly_addEdgeAttributes
#----------------------------------------------------------------------------------------------------
test_dataFramesToJSON_explicitNodePositions <- function(display)
{
   message(sprintf("--- test_dataFramesToJSON_explicitNodePositions"))

   tbl.nodes <- data.frame(id=c("A", "B", "C"),
                           type=c("kinase", "TF", "glycoprotein"),
                           x=c(0, 100, 200),
                           y=c(200, 100, 0),
                           lfc=c(1, 1, 1),
                           count=c(0, 0, 0),
                           stringsAsFactors=FALSE)

   tbl.edges <- data.frame(source=c("A", "B", "C"),
                           target=c("B", "C", "A"),
                           interaction=c("phosphorylates", "synthetic lethal", "unknown"),
                           stringsAsFactors=FALSE)

   g.json <- dataFramesToJSON(tbl.edges, tbl.nodes)
   x <- fromJSON(g.json)$elements
   checkEquals(names(x), c("nodes", "edges"))
     # make sure the xPos and yPos were translated into
     #   "position": {"x": 0.000000, "y": 200.000000}
     # data members for each node.  this is visible as position.x, position.y colnames
     # of the fromJSON result just above

   checkTrue(all(c("x", "y") %in% colnames(x$nodes$position)))
   checkEquals(x$nodes$position$x, c(0, 100, 200))
   checkEquals(x$nodes$position$y, c(200, 100, 0))

   tbl.nodes <- x$nodes$data
   checkEquals(dim(tbl.nodes), c(3, 6))
   checkEquals(tbl.nodes$id, c("A", "B", "C"))
   checkEquals(colnames(tbl.nodes), c("id", "type", "x", "y", "lfc", "count"))

   tbl.edges <- x$edges$data
   checkEquals(dim(tbl.edges), c(3, 4))
   checkEquals(colnames(tbl.edges), c("id", "source", "target", "interaction"))
   checkEquals(tbl.edges$id, c("A-(phosphorylates)-B", "B-(synthetic lethal)-C", "C-(unknown)-A"))

   if(display){
      writeLines(sprintf("network = %s", g.json), "network.js")
      Sys.sleep(10)
      browseURL("cyjs-readNetworkFromFile.html")
      } # display

}  # test_dataFramesToJSON_explicitNodePositions
#----------------------------------------------------------------------------------------------------
# sometimes the incoming JSON object has multiple top-level fields, only one of which is "style".
# in other cases, the incoming object is an array of selector objects.  test successful
# equal handling of those two cases here.
test_readAndStandardizeJSONStyleFile <- function()
{
   message(sprintf("--- test_readAndStandardizeCytoscapeDesktopExportedStyle"))

     # this JSON file has 5 top level fields: format_version, generated_by,
     # target_cytoscapejs_version, title style.  we want just the last.

   file.1 <- system.file(package="cyjShiny", "extdata", "fromCytoscapeDesktop-3.7.2", "smallDemoStyle.json")
   checkTrue(file.exists(file.1))
   jsonText.1 <- readAndStandardizeJSONStyleFile(file.1)
   checkTrue("character" %in% is(jsonText.1))
   checkEquals(substring(jsonText.1, 1, 13), "[{\"selector\":")

   file.2 <- system.file(package="cyjShiny", "extdata", "basicStyle.js")
   checkTrue(file.exists(file.2))
   jsonText.2 <- readAndStandardizeJSONStyleFile(file.2)
   checkTrue("character" %in% is(jsonText.2))
   checkEquals(substring(jsonText.2, 1, 13), "[{\"selector\":")

} # test_readAndStandardizeCytoscapeDesktopExportedStyle
#----------------------------------------------------------------------------------------------------
# sometimes the incoming JSON object has
#   1) 5 top level fields, including the one we want, "elements"
#   2) 1 top level field, "elements", with two subfields, nodes and edges
#   3) 2 top level fields only, nodes and edges
# here we test for uniform treatment of all 3, producing just version 2 (elements only)
test_readAndStandardizeJSONNetworkFile <- function()
{
   message(sprintf("--- test_readAndStandardizeJSONNetworkFile"))

     # this JSON file has 5 top level fields: format_version, generated_by,
     # target_cytoscapejs_version, title style.  we want just the last.

   file.1 <- system.file(package="cyjShiny", "extdata", "jsonGraphFiles", "graphWithFiveTopLevelFields.json")
   file.2 <- system.file(package="cyjShiny", "extdata", "jsonGraphFiles", "graphWithElementsFieldOnly.json")
   file.3 <- system.file(package="cyjShiny", "extdata", "jsonGraphFiles", "graphWithNodesAndEdgesFields.json")
   checkTrue(file.exists(file.1))
   checkTrue(file.exists(file.2))
   checkTrue(file.exists(file.3))

   jsonText.1 <- readAndStandardizeJSONNetworkFile(file.1)
   checkEquals(substring(jsonText.1, 1, 22), "{\"elements\":{\"nodes\":[")
   checkTrue("character" %in% is(jsonText.1))

   jsonText.2 <- readAndStandardizeJSONNetworkFile(file.2)
   checkEquals(substr(jsonText.2, 1, 22), "{\"elements\":{\"nodes\":[")
   checkTrue("character" %in% is(jsonText.2))

   jsonText.3 <- readAndStandardizeJSONNetworkFile(file.3)
   checkEquals(substring(jsonText.3, 1, 22), "{\"elements\":{\"nodes\":[")
   checkTrue("character" %in% is(jsonText.3))

} # test_readAndStandardizeJSONNetworkFile
#----------------------------------------------------------------------------------------------------
# in early experiments with neo4j, I discovered a bug:  if node ids are not sequentially ordered,
# they break an assumption of the toJSON function.  this test provides a tbl.nodes unordered by id
test_unorderedNodeIDs <- function()
{
   message(sprintf("--- test_unorderedNodeIDs"))

   tbl.nodes <- data.frame(id=c("8","1","2"), label=c("N8", "N1", "N2"), stringsAsFactors=FALSE)
   tbl.edges <- data.frame(id=c(34,23), source=c("8", "2"), target=c("1", "8"),
                           interaction=c("causes", "modifies"), stringsAsFactors=FALSE)
   x <- fromJSON(dataFramesToJSON(tbl.edges, tbl.nodes), simplifyDataFrame=TRUE)
   tbl.e <- x$elements$edges
   tbl.n <- x$elements$nodes

      # fromJSON nests data.frames within the edge and node data.frames
      # not knowing how to fix that, I accomodate that here, reaching
      # deeper into the data structure to make comparisons

      # start by checking the out-of-ascending order N8-causes-N1

   checkEquals(as.character(tbl.e[1,1][, c("source", "target", "interaction")]),
               c("8", "1", "causes"))
   checkEquals(as.character(tbl.e[2,1][, c("source", "target", "interaction")]),
               c("2", "8", "modifies"))

   checkEquals(as.character(tbl.n[1,1]), c("1", "N1"))
   checkEquals(as.character(tbl.n[2,1]), c("2", "N2"))
   checkEquals(as.character(tbl.n[3,1]), c("8", "N8"))

} # test_unorderedNodeIDs
#----------------------------------------------------------------------------------------------------
if(!interactive()) runTests()
