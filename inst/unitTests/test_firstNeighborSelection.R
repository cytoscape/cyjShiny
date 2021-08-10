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


firstNeighborsSelectionTest = R6Class("firstNeighborsSelectionTest",
                        
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
                            selectInput("selectName", "Select Node by ID:", choices = c("", sort(tbl.nodes$id))),
                            actionButton("sfn", "Select First Neighbor"),HTML("<br><br>"),
                        ),
                        mainPanel(cyjShinyOutput('cyjShiny', height=400),width=9)
                        ) # sidebarLayout
                    )}, # ui
                    
                    #------------------------------------------------------------
                    server = function(input, output, session){
                    
                    
                    output$cyjShiny <- renderCyjShiny({
                        cyjShiny(graph=graph.json, layoutName="preset")
                    })
                    
                    observeEvent(input$selectName,  ignoreInit=TRUE,{
                        selectNodes(session, input$selectName)
                    })
                    
                    observeEvent(input$sfn,  ignoreInit=TRUE,{
                        selectFirstNeighbors(session)
                    })
                    

                } # server
                          
            ) # public
) # class
#--------------------------------------------------------------------------------
x <- firstNeighborsSelectionTest$new()
runApp(shinyApp(x$ui, x$server), port=9999, launch.browser=TRUE)