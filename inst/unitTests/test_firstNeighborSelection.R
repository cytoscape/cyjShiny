library(shiny)
library(R6)
library(cyjShiny)
library(later)
library(RUnit)

#----------------------------------------------------------------------------------------------------
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


SelectionTest = R6Class("SelectionTest",
                        
                        #--------------------------------------------------------------------------------
                        private = list(currentlySelectedNodes=NULL,
                                       testResult=NULL
                        ),
                        
                        #--------------------------------------------------------------------------------
                        public = list(
                          
                          initialize = function(){
                            message(sprintf("initializing demo"))
                          },
                          
                          #------------------------------------------------------------
                          ui = function(){
                            fluidPage(
                              titlePanel(title="cyjShiny automated test"),
                              sidebarLayout(
                                sidebarPanel(
                                  actionButton("sfn", "Select First Neighbor")
                                ),
                                mainPanel(cyjShinyOutput('cyjShiny', height=400),width=9)
                              ) # sidebarLayout
                            )}, # ui
                          
                          #------------------------------------------------------------
                          server = function(input, output, session){
                            runNodeSelectionTest <- function(){
                              private$testResult <- FALSE  # be pessimistic
                              clearSelection(session);
                              targetNodes <- c("X")
                              later(function(){
                                selectNodes(session, targetNodes)
                                later(function(){
                                  getSelectedNodes(session)
                                  selectFirstNeighbors(session)
                                  later(function(){
                                    message(sprintf("about to check currentlySelectedNodes"))
                                    message(sprintf("targetNodes: %s", paste(targetNodes, collapse=",")))
                                    private$testResult <- checkEquals(private$currentlySelectedNodes, targetNodes)
                                    message(sprintf("test result: %s", private$testResult))
                                  }, 0.5)
                                }, 0.5)
                              }, 0.5)
                            } # runNodeSelectionTest
                            
                            output$cyjShiny <- renderCyjShiny({
                              cyjShiny(graph=graph.json, layoutName="preset")
                            })
                            
                            
                            observeEvent(input$sfn,  ignoreInit=TRUE,{
                              runNodeSelectionTest()
                              later(function(){message(sprintf("after test, result: %s", private$testResult))},2.0)
                            })
                            
                            
                            observeEvent(input$selectedNodes, {
                              message(sprintf("--- observing input$selectedNodes"))
                              private$currentlySelectedNodes = input$selectedNodes;
                            })
                            
                            if(!interactive()){
                              runNodeSelectionTest()
                              later(function(){
                                stopifnot(private$testResult == TRUE)
                                quit()
                              }, 5)
                            }
                            
                            
                          } # server
                          
                        ) # public
) # class
#--------------------------------------------------------------------------------
x <- SelectionTest$new()
runApp(shinyApp(x$ui, x$server), port=9999, launch.browser=TRUE)
