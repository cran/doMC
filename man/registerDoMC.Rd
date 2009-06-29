\name{registerDoMC}
\alias{registerDoMC}
\title{registerDoMC}
\description{
The \code{registerDoMC} function is used to register the multicore
parallel backend with the \code{foreach} package.
}
\usage{
registerDoMC(cores=NULL)
}
\arguments{
  \item{cores}{The number of cores to use for parallel execution. If not
  specified, the number of cores is set to the value of 
  \code{options("cores")}, if specified, or to the number of cores detected
  by the \code{multicore} package.}
}
\details{
The \code{multicore} package by Simon Urbanek provides functions for parallel
execution of R code on machines with multiple cores or processors, using
the system \code{fork} call to spawn copies of the current process. The
\code{multicore} package, and therefore \code{registerDoMC}, should not be used
in a GUI environment, because multiple processes then share the same GUI.
}
\keyword{utilities}
