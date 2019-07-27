\name{registerDoMC}
\alias{registerDoMC}
\title{registerDoMC}
\description{
The \code{registerDoMC} function is used to register the multicore
parallel backend with the \code{foreach} package.
}
\usage{
registerDoMC(cores=NULL, \dots)
}
\arguments{
  \item{cores}{The number of cores to use for parallel execution. If not
  specified, the number of cores is set to the value of 
  \code{options("cores")}, if specified, or to approximately half
  the number of cores detected
  by the \code{parallel} package.}
  \item{\dots}{Package options.  Currently, only the \code{nocompile} option
  is supported.  If \code{nocompile} is set to \code{TRUE}, compiler
  support is disabled.}
}
\details{
The \code{multicore} functionality, originally written by Simon Urbanek and
subsumed in the \code{parallel} package in R 2.14.0, provides functions 
for parallel execution of R code on machines with multiple cores or 
processors, using
the system \code{fork} call to spawn copies of the current process. The
\code{multicore} functionality, and therefore \code{registerDoMC}, should 
not be used
in a GUI environment, because multiple processes then share the same GUI.
}
\keyword{utilities}
