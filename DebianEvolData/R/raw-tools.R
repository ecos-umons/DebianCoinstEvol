RunCeveCUDF <- function(date, version, datadir) {
  src <- GetFilename(version, date, "gz", dirs=c(datadir, "dcf"))
  dest <- GetFilename(version, date, "cudf", dirs=c(datadir, "cudf"))
  log <- ReplaceExtension(dest, "log")
  args <- c("-T", "cudf", sprintf("deb://%s", src))
  loginfo(sprintf("Ceve (CUDF) on %s", src),
          logger="raw.tools.ceve.cudf")
  t <- system.time(system2("dose-ceve", args=args, stdout=dest, stderr=log))
  system2("gzip", dest)
  loginfo(sprintf("Ceve (CUDF) on %s: %.2f", src, t[3]),
          logger="raw.tools.ceve.cudf")
  t
}

RunCeveGraphML <- function(date, version, datadir) {
  src <- GetFilename(version, date, "gz", dirs=c(datadir, "dcf"))
  dest <- GetFilename(version, date, "graphml", dirs=c(datadir, "deps"))
  log <- ReplaceExtension(dest, "log")
  args <- c("-T", "grml", "-G", "pkg", sprintf("deb://%s", src))
  loginfo(sprintf("Ceve (GraphML) on %s", src),
          logger="raw.tools.ceve.graphml")
  t <- system.time(system2("dose-ceve", args=args, stdout=dest, stderr=log))
  system2("gzip", dest)
  loginfo(sprintf("Ceve (GraphML) on %s: %.2f", src, t[3]),
          logger="raw.tools.ceve.graphml")
  t
}

RunCoinst <- function(date, version, datadir) {
  src <- GetFilename(version, date, "gz", dirs=c(datadir, "dcf"))
  dest <- GetFilename(version, date, "dot", dirs=c(datadir, "coinst"))
  log <- ReplaceExtension(dest, "log")
  json <- ReplaceExtension(dest, "json")
  args <- c(3600, "coinst", "-all", "-conflicts", json, src, "-o", dest)
  loginfo(sprintf("Coinst on %s", src),
          logger="raw.tools.coinst")
  t <- system.time(system2("timeout", args=args, stdout=log, stderr=log))
  loginfo(sprintf("Coinst on %s: %.2f", src, t[3]),
          logger="raw.tools.coinst")
  t
}

RunOnHistory <- function(history, datadir, CMD, cl) {
  if (nrow(history)) {
    clusterApplyLB(cl, history$date, CMD, history$version[1], datadir)
  }
}

RunTools <- function(history, datadir, cl) {
  RunOnHistory(history[!file.exists(GetFilename(version, date, "cudf.gz",
                                                dirs=c(datadir, "cudf")))],
               datadir, RunCeveCUDF, cl)
  RunOnHistory(history[!file.exists(GetFilename(version, date, "graphml.gz",
                                                dirs=c(datadir, "deps")))],
               datadir, RunCeveGraphML, cl)
  RunOnHistory(history[!file.exists(GetFilename(version, date, "dot",
                                                dirs=c(datadir, "coinst")))],
               datadir, RunCoinst, cl)
}
