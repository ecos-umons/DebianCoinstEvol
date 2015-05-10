RawData <- function(versions, url="http://snapshot.debian.org/archive/debian/",
                    datadir="data", logdir="log", n=6,
                    download=TRUE, run.tools=TRUE, filter.coinst=NULL) {
  basicConfig()
  logfile <- file.path(logdir, "raw.log")
  addHandler(writeToFile, logger="raw", file=logfile)

  DoCluster(function(cl) {
    if (download) {
      for (version in versions) {
        DownloadHistory(version, url, datadir)
      }
    }

    if (run.tools) {
      for (version in versions) {
        history <- readRDS(file.path(datadir, sprintf("%s.rds", version)))

        message(sprintf("Running Ceve (CUDF) on %s", version))
        t <- system.time({
          filenames <- GetFilename(version, history$date, "cudf.gz",
                                   dirs=c(datadir, "cudf"))
          RunOnHistory(history[!file.exists(filenames)],
                       datadir, RunCeveCUDF, cl)
        })
        print(t)

        message(sprintf("Running Ceve (GraphML) on %s", version))
        t <- system.time({
          filenames <- GetFilename(version, history$date, "graphml.gz",
                                   dirs=c(datadir, "deps"))
          RunOnHistory(history[!file.exists(filenames)],
                       datadir, RunCeveGraphML, cl)
        })
        print(t)

        message(sprintf("Running Coinst on %s", version))
        t <- system.time({
          filenames <- GetFilename(version, history$date, "dot",
                                   dirs=c(datadir, "coinst"))
          if (!is.null(filter.coinst)) {
            RunOnHistory(history[!file.exists(filenames) & date >= filter.coinst],
                         datadir, RunCoinst, cl)
          } else {
            RunOnHistory(history[!file.exists(filenames)],
                         datadir, RunCoinst, cl)
          }
        })
        print(t)
      }
    }
  }, logger="raw", logfile=logfile, n=n)
}

ParseData <- function(versions, datadir="data", logdir="log", n=4) {
  basicConfig()
  logfile <- file.path(logdir, "parse.log")
  addHandler(writeToFile, logger="parse", file=logfile)

  DoCluster(function(cl) {
    for (version in versions) {
      history <- readRDS(file.path(datadir, sprintf("%s.rds", version)))
      message(sprintf("Parsing DCF of %s", version))
      t <- system.time(ConvertDCF(history, datadir, cl))
      print(t)

      message(sprintf("Parsing CUDF of %s", version))
      t <- system.time(ConvertCUDF(history, datadir, cl))
      print(t)

      ## message(sprintf("Parsing dependencies of %s", version))
      ## t <- system.time(ConvertDependencies(history, datadir, cl))
      ## print(t)

      message(sprintf("Parsing Coinst JSON of %s", version))
      t <- system.time(ConvertCoinst(history, datadir, cl))
      print(t)
    }
  }, logger="parse", logfile=logfile, n=n)
}

ProcessData <- function(versions, datadir="data", logdir="log", n=6) {
  basicConfig()
  logfile <- file.path(logdir, "process.log")
  addHandler(writeToFile, logger="process", file=logfile)

  DoCluster(function (cl) {
    for (version in versions) {
      history <- readRDS(file.path(datadir, sprintf("%s.rds", version)))

      message(sprintf("Processing strong conflicts of %s", version))
      t <- system.time(ProcessStrongConflicts(history, datadir, cl))
      print(t)

      ## message(sprintf("Processing conflicts of %s", version))
      ## t <- system.time(ProcessConflicts(history, datadir, cl))
      ## print(t)

      ## message(sprintf("Processing deps of %s", version))
      ## t <- system.time(ProcessDependencies(history, datadir, cl))
      ## print(t)
    }
  }, logger="process", logfile=logfile, n=n)
}

AggregateData <- function(versions, datadir="data", logdir="log") {
  basicConfig()
  logfile <- file.path(logdir, "aggregate.log")
  addHandler(writeToFile, logger="aggregate", file=logfile)

  for (version in versions) {
    ## AggregateMatrices(version, datadir)
    ## AggregateDiffs(version, datadir)
    AggregateDiffHistory(version, datadir)
    ## AggregateHistory(version, datadir)
    ## AggregatePackageMetrics(version, datadir)
    ## AggregatePackageSurvival(version, datadir)
    ## AggregateConflictSurvival(version, datadir)
  }
}
