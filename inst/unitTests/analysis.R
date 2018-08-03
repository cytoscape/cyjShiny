#--------------------------------------------------------------------------------
community.newman <- function(gi)
{
    deg <- igraph::degree(gi)
    ec <- ecount(gi)
    B <- get.adjacency(gi) - outer(deg, deg, function(x,y) x*y/2/ec)
    diag(B) <- 0
    eigen(B)$vectors[,1]
} #community.newman
#--------------------------------------------------------------------------------
test_community.newman <- function()
{
    print("---test_community.newman")
    load("interaction_bundle-2018-07-24.RData")
    tbl <- fix(tbl) #organize.R

    tbl$signature <- paste(tbl$a, tbl$b, sep=":")
    gnel <- new("graphNEL", edgemode="undirected")
    all.nodes <- c(unique(c(tbl$a, tbl$b)))
    duplicated.interactions <- which(duplicated(tbl$signature))
    tbl.unique <- tbl[-duplicated.interactions,]
    gnel <- graph::addNode(all.nodes, gnel)
    gnel <- graph::addEdge(tbl.unique$a, tbl.unique$b, gnel)
    gi <- igraph.from.graphNEL(gnel, name=TRUE, weight=TRUE, unlist.attrs=TRUE)
    newman <- community.newman(gi)
   
    checkEquals(length(newman), 123)
    
}#test_community.newman
#--------------------------------------------------------------------------------
#EXTRA STUFF FOR ANALYSIS

scale <- function(v, a, b)
{
    v <- v-min(v) ; v <- v/max(v) ; v <- v * (b-a) ; v+a
} #scale


run <- function()
{
    newm <- community.newman(gi)
    browser()
    V(gi)$color <- ifelse(newm < 0, "grey", "green")
    V(gi)$size <- scale(abs(newm), 15, 25)
    E(gi)$color <- "grey"
    E(gi)[ V(gi)[color=="grey"] %--% V(gi)[color=="green"] ]$color <- "red"
    
    plot(gi, layout=layout.kamada.kawai,
         vertex.color="a:color",
         vertex.size="a:size",
         edge.color="a:color")
}# run
#------------------------------------------------------------------------------------------

