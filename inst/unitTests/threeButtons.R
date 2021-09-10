library(shiny)
library(R6)

MyModule = R6Class("MyModule",
    #--------------------------------------------------------------------------------
    public = list(
      initialize = function(){
      message(sprintf("initializing demo"))
      },
                          
      #------------------------------------------------------------
      ui = function(){
        fluidPage(
          titlePanel(title="three button test"),
          br(),                                                       # empty line
          actionButton(inputId = "ClickonMe", label = "Make Text"),   # button 1
          actionButton(inputId = "ClickonMe2", label = "Print Text"), # button 2
          actionButton(inputId = "ClickonMe3", label = "Clear Text"),
          mainPanel(verbatimTextOutput("Responsetext"))
           # sidebarLayout
          )}, # ui
                          
      #------------------------------------------------------------
      server = function(input, output, session){
        values <- reactiveValues()
        values$name <- NULL
                            
        observeEvent(input$ClickonMe, ignoreInit=TRUE, {
          values$name <- TRUE
        })

        observeEvent(input$ClickonMe3,{
          if (values$name){ 
            values$name <- FALSE
          }
        })
        observeEvent(input$ClickonMe2,{
          if (values$name){
            print("HELLO WORLD")
          }
        }) 
                            
        output$Responsetext <- renderPrint({
          req(values$name)
          if(!values$name){
            removeUI(
            selector = "div:has(> #Responsetext)"
            )
          }
          as.character("HELLO WORLD")})
                            
      } # server
                          
    ) # public
) # class
#--------------------------------------------------------------------------------
x <- MyModule$new()
runApp(shinyApp(x$ui, x$server), port=9999, launch.browser=TRUE)
