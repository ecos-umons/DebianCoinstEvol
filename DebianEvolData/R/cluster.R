DoCluster <- function(DO, logger, logfile, n=6, outfile="") {
  cl <- makeCluster(n, type="PSOCK", outfile="")
  clusterExport(cl, list(logfile="logfile"), envir=environment())
  clusterCall(cl, function() {
    library(logging)
    library(DebianEvolData)

    basicConfig()
    addHandler(writeToFile, logger="raw", file=logfile)
  })
  DO(cl)
  stopCluster(cl)
}
