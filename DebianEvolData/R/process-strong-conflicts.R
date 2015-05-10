ConflictMetrics <- function(date, version, datadir) {
  LogTime(version, date, function() {
    coinst <- readRDS(GetFilename(version, date, "rds", dirs=c(datadir, "coinst")))
    dcf <- readRDS(GetFilename(version, date, "rds", dirs=c(datadir, "dcf")))
    res <- coinst$classes[unique(dcf$package), allow.cartesian=TRUE]
    classes <- res[, list(class.size=if (is.na(class)) 0L else .N), by="class"]
    setkey(classes, class)
    conflicts <- lapply(classes$class, function(c) coinst$incomp[x == c, y])
    names(conflicts) <- classes$class
    res[, conflicts.all := sapply(conflicts[class], function(c) {
      if (is.null(c)) 0 else sum(classes[c, class.size])
    })]
    res[, conflicts := sapply(conflicts[class], length)]
  }, "Process strong conflicts", "process.strongconflicts")
}

ProcessStrongConflicts <- function(history, datadir, cl=NULL) {
  history[, dest := GetFilename(version, date, "rds",
                                dirs=c(datadir, "strong-conflicts"))]
  history <- history[file.exists(GetFilename(version, date, "rds",
                                             dirs=c(datadir, "coinst"))) &
                     file.exists(GetFilename(version, date, "rds",
                                             dirs=c(datadir, "dcf")))]
  ApplyHistory(history, datadir, ConflictMetrics, cl=cl)
}
