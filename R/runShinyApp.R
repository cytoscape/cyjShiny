#' Run Shiny App
#' 
#' @param launch.browser launch in browser? (default: TRUE)
#' @param port port number to use
#' @return None
#'
#' @examples
#' port <-3838
#' # Uncomment first
#' #runShinyApp(port=port)
#' 
#' @export
#' 
#' @importFrom shiny runApp
runShinyApp <- function(launch.browser=TRUE, port=3838) {
	runApp(system.file(file.path('examples', 'shiny'), package='rcytoscapejs'), 
	       launch.browser=launch.browser, port=port)	
}

