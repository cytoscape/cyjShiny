library(shiny)
library(R6)

#------------------------------------------------------------------------
MyModule <- R6Class(

  #-------------------------------------------------------------
  public = list(
    initialize = function(id = shiny:::createUniqueId()){
      private$id <- id
    },

    bind = function(){
      callModule(private$moduleserver, private$id)
    },
  #--------------------------------------------------------------------------
    ui = function(ns = NS(NULL)){
      ns <- NS(ns(private$id))
      fluidPage(
        h3("Hello there"),                                          # First text on the window
        br(),                                                       # empty line
        actionButton(inputId = ns("ClickonMe"), label = "Make Text"),   # button 1
        actionButton(inputId = ns("ClickonMe2"), label = "Print Text"), # button 2
        actionButton(inputId = ns("ClickonMe3"), label = "Clear Text"),
        mainPanel(verbatimTextOutput(ns("Responsetext")))
      )
    }
  ),
#----------------------------------------------------------------------------------
  private = list(
    id = NULL,
    moduleserver = function(input, output, session){
      ns <- session$ns
      values <- reactiveValues()
      values$name <- NULL
  #------------------------------------------------------------------------------------    
      observeEvent(input$ClickonMe,{
        values$name <- T 
      })
  #-------------------------------------------------------------------------------------    
      observeEvent(input$ClickonMe3,{
        if (values$name){ 
          values$name <- F
          }
      })
  #-------------------------------------------------------------------------------------    
      observeEvent(input$ClickonMe2,{
        if (values$name){
          print(values$name)
        }
      }) 
  #-------------------------------------------------------------------------------------    
      output$Responsetext <- renderPrint({
        req(values$name)
        if(!values$name){
          removeUI(
            selector = "div:has(> #Responsetext)"
          )
        }
        as.character(values$name)})
    }
  )
)
#------------------------------------------------------------------------------------------

myObj <- MyModule$new()

runApp(
shinyApp(
  myObj$ui(),
  function(input, output, session){ myObj$bind() }
),
port=9999, launch.browser=TRUE)
