library(shiny)
library(R6)
library(cyjShiny)
library(later)
library(RUnit)

#----------------------------------------------------------------------------------------------------
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
buttonStyle <- "margin: 5px; margin-right: 0px; font-size: 14px;"

g <- createTestGraph(200, 200)
graph.json <- graphNELtoJSON(g)


PositionTest = R6Class("PositionTest",

    #--------------------------------------------------------------------------------
    private = list(positions=NULL,
                   testResult=NULL
                   ),

    #--------------------------------------------------------------------------------
    public = list(

        initialize = function(){
            message(sprintf("initializing PositionTest"))
            },

        #------------------------------------------------------------
        ui = function(){
           fluidPage(
               titlePanel(title="cyjShiny layouts test"),
               sidebarLayout(
                   sidebarPanel(
                       radioButtons("chooseLayout", "Select Layout:",
                                    choices=c("breadthfirst",
                                              "circle",
                                              "cola",
                                              "concentric",
                                              "cose",
                                              "fcose",
                                              "grid",
                                              "klay",
                                              "random",
                                              "spread",
                                              "springy"),
                                    selected="concentric"),
                       actionButton("testInitialNodePositionsButton", "Test Initial Node Positions"),
                       actionButton("setNewNodePositionsButton", "Set New Positions"),
                       actionButton("resetInitialNodePositionsButton", "Reset Initial Node Positions"),
                       HTML("<br><br>"),
                       div(style="border: 1px solid black; border-radius: 5px; height:100px; padding:10px; background-color: white;",
                           textOutput(outputId="resultsBox")),
                       width=3
                       ),
                   mainPanel(cyjShinyOutput('cyjShiny', height=700),width=9)
               ) # sidebarLayout
            )}, # ui

        #------------------------------------------------------------
        server = function(input, output, session){

            runInitialNodePositionTest <- function(){
               private$testResult <- FALSE  # be pessimistic
               output$resultsBox <- renderText({""});
               later(function(){
                  getNodePositions(session)
                  later(function(){
                     message(sprintf("--- executing runInitialNodePositionTest's later function"))
                     private$testResult <- all(private$positions == tbl.nodes[, c("id", "x", "y")])
                     message(sprintf("test result: %s", private$testResult))
                     output$resultsBox <- renderText({private$testResult});
                     }, 1)
                  }, 1)
               } # runInitialNodePositionTest

            setNewNodePositions <- function(){
               tbl.new <- tbl.nodes[, c("id", "x", "y")]
                  # reverse x and y
               y.orig <- tbl.new$y
               tbl.new$y <- tbl.new$x
               tbl.new$x <- y.orig
               setNodePositions(session, tbl.new)
               fit(session)
               } # setNewNodePositions

            observeEvent(input$chooseLayout,  ignoreInit=TRUE,{
                strategy <- input$chooseLayout
                doLayout(session, strategy)
                })

            output$cyjShiny <- renderCyjShiny({
               cyjShiny(graph=graph.json, layoutName="concentric")
               })

            observeEvent(input$testInitialNodePositionsButton, ignoreInit=TRUE, {
                runInitialNodePositionTest()
                })

            observeEvent(input$resetInitialNodePositionsButton, ignoreInit=TRUE, {
               setNodePositions(session, tbl.nodes[, c("id", "x", "y")])
               fit(session)
               })

            observeEvent(input$setNewNodePositionsButton, ignoreInit=TRUE, {
               setNewNodePositions()
               })

            observeEvent(input$tbl.nodePositions, ignoreInit=TRUE, {
               message(sprintf("--- observing input$tbl.nodePositions"))
               private$positions = fromJSON(input$tbl.nodePositions);
               printf("--- tbl.nodePositions arrived")
               print(private$positions)
               })

            if(!interactive()){
               runInitialNodePositionTest()
               later(function(){
                  printf("initial node test: private$testResult: %s", private$testResult)
                  stopifnot(private$testResult == TRUE)
                  setNewNodePositions()
                  later(function(){
                      runInitialNodePositionTest()
                      later(function(){
                          printf("nodes moved, private$testResult: %s", private$testResult)
                          stopifnot(private$testResult == FALSE)
                          quit()
                          }, 3)
                      }, 3)
                  }, 3)
                } # !interactive

            } # server

       ) # public
    ) # class
#--------------------------------------------------------------------------------
x <- PositionTest$new()
runApp(shinyApp(x$ui, x$server), port=9998, launch.browser=TRUE)
