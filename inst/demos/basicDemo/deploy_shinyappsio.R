# This script deploys an example to shinyapps.io; 
# NOTE: The RStudio GUI button for this may not work, but it is necessary to run the GUI button at least once to generate the rconnect folder
rep <- c(CRAN="https://cran.rstudio.com/", "BioCsoft"="https://bioconductor.org/packages/3.10/bioc")
options(repos = rep)
options("repos")
rsconnect::deployApp(appDir="inst/demos/basicDemo")
