#
# Copyright (c) 2008-2009, REvolution Computing, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# this explicitly registers a multicore parallel backend
registerDoMC <- function(cores=NULL) {
  setDoPar(doMC, cores, info)
}

# internal function that determines the number of workers to use
workers <- function(cores) {
  if (!is.null(cores)) {
    # use the number specified when registering doMC
    cores
  } else {
    cores <- getOption('cores')
    if (!is.null(cores))
      # use the number specified via the 'cores' option
      cores
    else
      # use the number detected by multicore
      multicore:::volatile$detectedCores
  }
}

# passed to setDoPar via registerDoMC, and called by getDoParWorkers, etc
info <- function(data, item) {
  switch(item,
         workers=workers(data),
         name='doMC',
         version=packageDescription('doMC', fields='Version'),
         NULL)
}

doMC <- function(obj, expr, envir, data) {
  # set the default mclapply options
  preschedule <- TRUE
  set.seed <- TRUE
  silent <- FALSE
  cores <- workers(data)

  if (!inherits(obj, 'foreach'))
    stop('obj must be a foreach object')

  it <- iter(obj)
  argsList <- as.list(it)
  accumulator <- makeAccum(it)

  # make sure all of the necessary libraries have been loaded
  for (p in obj$packages)
    library(p, character.only=TRUE)

  # check for multicore-specific options
  options <- obj$options$multicore
  if (!is.null(options)) {
    nms <- names(options)
    recog <- nms %in% c('preschedule', 'set.seed', 'silent', 'cores')
    if (any(!recog))
      warning(sprintf('ignoring unrecognized multicore option(s): %s',
                      paste(nms[!recog], collapse=', ')), call.=FALSE)

    if (!is.null(options$preschedule)) {
      if (!is.logical(options$preschedule) || length(options$preschedule) != 1) {
        warning('preschedule must be logical value', call.=FALSE)
      } else {
        if (obj$verbose)
          cat(sprintf('setting mc.preschedule option to %d\n', options$preschedule))
        preschedule <- options$preschedule
      }
    }

    if (!is.null(options$set.seed)) {
      if (!is.logical(options$set.seed) || length(options$set.seed) != 1) {
        warning('set.seed must be logical value', call.=FALSE)
      } else {
        if (obj$verbose)
          cat(sprintf('setting mc.set.seed option to %d\n', options$set.seed))
        set.seed <- options$set.seed
      }
    }

    if (!is.null(options$silent)) {
      if (!is.logical(options$silent) || length(options$silent) != 1) {
        warning('silent must be logical value', call.=FALSE)
      } else {
        if (obj$verbose)
          cat(sprintf('setting mc.silent option to %d\n', options$silent))
        silent <- options$silent
      }
    }

    if (!is.null(options$cores)) {
      if (!is.numeric(options$cores) || length(options$cores) != 1 ||
          options$cores < 1) {
        warning('cores must be numeric value >= 1', call.=FALSE)
      } else {
        if (obj$verbose)
          cat(sprintf('setting mc.cores option to %d\n', options$cores))
        cores <- options$cores
      }
    }
  }

  # execute the tasks
  FUN <- function(args) eval(expr, envir=args, enclos=envir)
  results <- mclapply(argsList, FUN, mc.preschedule=preschedule,
                      mc.set.seed=set.seed, mc.silent=silent,
                      mc.cores=cores)

  # call the accumulator with all of the results
  tryCatch(accumulator(results, seq(along=results)), error=function(e) {
    cat('error calling combine function:\n')
    print(e)
    NULL
  })

  # check for errors
  errorValue <- getErrorValue(it)
  errorIndex <- getErrorIndex(it)

  # throw an error or return the combined results
  if (identical(obj$errorHandling, 'stop') && !is.null(errorValue)) {
    msg <- sprintf('task %d failed - "%s"', errorIndex,
                   conditionMessage(errorValue))
    stop(simpleError(msg, call=expr))
  } else {
    getResult(it)
  }
}
