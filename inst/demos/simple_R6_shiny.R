library(shiny)
library(R6)

#----------------------------------------------------------------------------------------------------
buttonStyle <- "margin: 5px; margin-right: 0px; font-size: 14px;"


Simple.R6.Shiny = R6Class("Simple.R6.Shiny",

    #--------------------------------------------------------------------------------
    private = list(currentValue=NULL),

    #--------------------------------------------------------------------------------
    public = list(

        initialize = function(){
            message(sprintf("initializing Simple.R6.shiny app"))
            private$currentValue <- 0
            },

        #------------------------------------------------------------
        ui = function(){
           fluidPage(
               titlePanel(title="Simple R6 shiny"),
               sidebarLayout(
                   sidebarPanel(
                       actionButton("incrementValueButton", "Increment Value"), HTML("<br><br>"),
                       actionButton("printValueButton", "Print Value to stdout"),
                       width=3
                       ),
                   mainPanel(div(),width=9)
               ) # sidebarLayout
            )}, # ui

        #------------------------------------------------------------
        server = function(input, output, session){

            observeEvent(input$incrementValueButton, ignoreInit=TRUE, {
                private$currentValue <- private$currentValue + 1
                })

            observeEvent(input$printValueButton, ignoreInit=TRUE, {
               message(sprintf("currentValue: %d", private$currentValue))
               })
            } # server

       ) # public
    ) # class
#--------------------------------------------------------------------------------
app <- Simple.R6.Shiny$new()
runApp(shinyApp(app$ui, app$server), port=9999, launch.browser=TRUE)

