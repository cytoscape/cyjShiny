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



SelectionTest = R6Class("SelectionTest",

    #--------------------------------------------------------------------------------
    private = list(currentlySelectedNodes=NULL,
                   testResult=NULL
                   ),

    #--------------------------------------------------------------------------------
    public = list(

        initialize = function(){
            printf("initializing demo")
            },

        #------------------------------------------------------------
        ui = function(){
           fluidPage(
               titlePanel(title="cyjShiny automated test"),
               sidebarLayout(
                   sidebarPanel(
                       actionButton("testGetSelectedNodesButton", "Test Get Selected Nodes"), HTML("<br><br>"),
                       width=3
                       ),
                   mainPanel(cyjShinyOutput('cyjShiny', height=400),width=9)
               ) # sidebarLayout
            )}, # ui

        #------------------------------------------------------------
        server = function(input, output, session){

            runNodeSelectionTest <- function(){
               private$testResult <- FALSE  # be pessimistic
               clearSelection(session);
               targetNodes <- c("X", "Z")
               later(function(){
                  selectNodes(session, targetNodes)
                  later(function(){
                     getSelectedNodes(session)
                     later(function(){
                        private$testResult <- checkEquals(private$currentlySelectedNodes, targetNodes)
                        printf("test result: %s", private$testResult)
                        }, 0.5)
                     }, 0.5)
                  }, 0.5)
               } # runNodeSelectionTest

            output$cyjShiny <- renderCyjShiny({
               cyjShiny(graph=graph.json, layoutName="preset")
               })

            observeEvent(input$testGetSelectedNodesButton, ignoreInit=TRUE, {
                runNodeSelectionTest()
                later(function(){printf("after test, result: %s", private$testResult)}, 2.0)
                })

            observeEvent(input$selectedNodes, ignoreInit=TRUE, {
               private$currentlySelectedNodes = input$selectedNodes;
               })

            runNodeSelectionTest()
            } # server

       ) # public
    ) # class
#--------------------------------------------------------------------------------
app <- SelectionTest$new()
x <- shinyApp(app$ui, app$server)
runApp(x, port=1156)

