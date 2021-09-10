library(shiny)
library(R6)
library(cyjShiny)
library(later)
library(RUnit)

#----------------------------------------------------------------------------------------------------
buttonStyle <- "margin: 5px; margin-right: 0px; font-size: 14px;"

tbl.nodes <- data.frame(id=c("X", "Y", "Z"),
                        type=c("kinase", "TF", "glycoprotein"),
                        x=c(50, 180, 600),
                        y=c(150, 90, 150),
                        lfc=c(1, 1, 1),
                        count=c(0, 0, 0),
                        stringsAsFactors=FALSE)

tbl.edges <- data.frame(source=c("X", "Y", "Z"),
                        target=c("Y", "Z", "X"),
                        interaction=c("phosphorylates", "synthetic lethal", "unknown"),
                        stringsAsFactors=FALSE)

graph.json <- dataFramesToJSON(tbl.edges, tbl.nodes)



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
               titlePanel(title="cyjShiny get/set position test"),
               sidebarLayout(
                   sidebarPanel(
                       actionButton("testInitialNodePositionsButton", "Test Initial Node Positions"),
                       actionButton("setNewNodePositionsButton", "Set New Positions"),
                       actionButton("resetInitialNodePositionsButton", "Reset Initial Node Positions"),
                       HTML("<br><br>"),
                       div(style="border: 1px solid black; border-radius: 5px; height:100px; padding:10px; background-color: white;",
                           textOutput(outputId="resultsBox")),
                       width=3
                       ),
                   mainPanel(cyjShinyOutput('cyjShiny', height=400),width=9)
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

            output$cyjShiny <- renderCyjShiny({
               cyjShiny(graph=graph.json, layoutName="preset")
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
