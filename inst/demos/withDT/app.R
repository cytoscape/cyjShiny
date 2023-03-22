library(cyjShiny)
library(DT)
library(later)



#----------------------------------------------------------------------------------------------------
# create  data.frames for nodes, edges, and two simulated experimental variables, in 3 conditions
#----------------------------------------------------------------------------------------------------
tbl.nodes <- data.frame(id=c("A", "B", "C"),
                        type=c("kinase", "TF", "glycoprotein"),
                        lfc=c(1, 1, 1),
                        count=c(0, 0, 0),
                        stringsAsFactors=FALSE)

tbl.edges <- data.frame(source=c("A", "B", "C"),
                        target=c("B", "C", "A"),
                        interaction=c("phosphorylates", "synthetic lethal", "unknown"),
                        stringsAsFactors=FALSE)

graph.json <- dataFramesToJSON(tbl.edges, tbl.nodes)

tbl.lfc <- data.frame(A=c(0,  1,   1,  -3),
                      B=c(0,  3,   2,   3),
                      C=c(0, -3,  -2,  -1),
                      stringsAsFactors=FALSE)

rownames(tbl.lfc) <- c("baseline", "cond1", "cond2", "cond3")

tbl.count <- data.frame(A=c(1, 10,  100, 150),
                        B=c(1, 5,   80,  3),
                        C=c(1, 100, 50,  300),
                        stringsAsFactors=FALSE)

rownames(tbl.count) <- c("baseline", "cond1", "cond2", "cond3")

#----------------------------------------------------------------------------------------------------
ui = shinyUI(fluidPage(

  sidebarLayout(
      sidebarPanel(
          selectInput("doLayout", "Select Layout:",
                      choices=c("",
                                "cose",
                                "cola",
                                "circle",
                                "concentric",
                                "breadthfirst",
                                "grid",
                                "random",
                                "preset",
                                "fcose")),
          width=2
      ),
     mainPanel(fluidRow(
        cyjShinyOutput('cyjShiny', width="400px", height="200px"),
        DTOutput("table")
        ),
        width=10)
  ) # sidebarLayout
))
#----------------------------------------------------------------------------------------------------
server = function(input, output, session)
{
    observeEvent(input$doLayout,  ignoreInit=TRUE,{
       if(input$doLayout != ""){
          strategy <- input$doLayout
          doLayout(session, strategy)
          later(function() {updateSelectInput(session, "doLayout", selected=character(0))}, 1)
          }
       })

    output$cyjShiny <- renderCyjShiny({
       cyjShiny(graph=graph.json, layoutName="cola", height=300)
       })

   output$table = DT::renderDataTable(tbl.count,
                                      width="400px",
                                      class='nowrap display',
                                      selection="single",
                                      extensions="FixedColumns",
                                      options=list(dom='t',
                                                   paging=FALSE,
                                                   autowWdth=TRUE
                                                   ))


} # server
#----------------------------------------------------------------------------------------------------
app <- shinyApp(ui = ui, server = server)
