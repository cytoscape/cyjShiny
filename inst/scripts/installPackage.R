setRepositories(ind=1:6);
options(repos="http://cran.rstudio.com/");

if(!require(devtools)) { install.packages("devtools") };

library(devtools);

install_github("cytoscape/r-cytoscape.js", build_vignette=TRUE, dependencies=TRUE, args="--no-multiarch");