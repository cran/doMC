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
registerDoMC <- function() {
  setDoPar(doMC, NULL, info)
}

# passed to setDoPar via registerDoMC, and called by getDoParWorkers, etc
info <- function(data, item) {
  switch(item,
         workers= multicore:::volatile$detectedCores,
         name='doMC',
         version=packageDescription('doMC', fields='Version'),
         NULL)
}

doMC <- function(obj, expr, envir, data) {
  # note that the "data" argument isn't used
  if (!inherits(obj, 'foreach'))
    stop('obj must be a foreach object')

  it <- iter(obj)
  argsList <- as.list(it)
  accumulator <- makeAccum(it)

  # make sure all of the necessary libraries have been loaded
  for (p in obj$packages)
    library(p, character.only=TRUE)

  # execute the tasks
  results <- mclapply(argsList, function(args) {
    eval(expr, envir=args, enclos=envir)
  })

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
