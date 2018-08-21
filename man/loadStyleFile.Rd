% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cyjShiny.R
\name{loadStyleFile}
\alias{loadStyleFile}
\title{load a standard cytoscape.js style file}
\usage{
loadStyleFile(filename)
}
\arguments{
\item{filename}{character string, either relative or absolute path}
}
\value{
nothing
}
\description{
load a standard cytoscape.js style file
}
\examples{

loadStyleFile(system.file(package="cyjShiny", "extdata", "yeastGalactoseStyle.js"))

}