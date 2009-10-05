\name{doMC-package}
\alias{doMC-package}
\alias{doMC}
\docType{package}
\title{
The doMC Package
}
\description{
The doMC package provides a parallel backend for the foreach/\%dopar\%
function using Simon Urbanek's multicore package.
}
\details{
Further information is available in the following help topics:
\tabular{ll}{
\code{registerDoMC} \tab register doMC to be used by foreach/\%dopar\%\cr
}

To see a tutorial introduction to the doMC package,
use \code{vignette("gettingstartedMC")}.  To see a tutorial
introduction to the foreach package, use \code{vignette("foreach")}.

To see a demo of doMC computing the sinc function,
use \code{demo(sincMC)}.

Some examples (in addition to those in the help pages) are included in
the ``examples'' directory of the doMC package.  To list the files in
the examples directory,
use \code{list.files(system.file("examples", package="doMC"))}.
To run the bootstrap example, use
\code{source(system.file("examples", "bootMC.R", package="doMC"))}.
This is a simple benchmark, executing both sequentally and in parallel.
There are many more examples that come with the foreach package,
which will work with the doMC package if it is registered as the
parallel backend.

For a complete list of functions with individual help pages,
use \code{library(help="doMC")}.
}
\keyword{package}
