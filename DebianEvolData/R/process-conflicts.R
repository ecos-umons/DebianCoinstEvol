constraint.re <- " *([^ ]*)( *([<>=][<>=]?) *([^ ]+))? *"

ParsePackageConstraint <- function(package, version, col, col.name) {
  res <- data.table(package=package,
                    version=version,
                    x=sub(constraint.re, "\\1", col),
                    y=sub(constraint.re, "\\3", col),
                    z=sub(constraint.re, "\\4", col))
  res$y[res$y == "="] <- "=="
  setnames(res, c("x", "y", "z"),
           c(col.name, paste(col.name, c("constraint", "version"), sep=".")))
  res
}

ParseColumn <- function(cudf, col) {
  cudf[[col]] <- strsplit(cudf[[col]], ",|\\|")
  rbindlist(apply(cudf, 1, function(p) {
    ParsePackageConstraint(p[["package"]], p[["version"]], p[[col]], col)
  }))
}

ParseConflicts <- function(cudf) {
  cudf <- cudf[sapply(strsplit(cudf$conflicts, ","), length) > 1]
  res <- ParseColumn(cudf, "conflicts")
  res[package != conflicts]
}

ParseProvides <- function(cudf) {
  cudf <- cudf[!is.na(provides)]
  ParseColumn(cudf, "provides")
}

DirectConflicts <- function(cudf, conflicts) {
  # Conflicts with physical packages
  cudf <- cudf[, list(conflicts=package, conflicts.actual.version=version)]
  res <- merge(conflicts, cudf, by="conflicts")
  res[by(res, 1:nrow(res), function(p) {
    if (p$conflicts.version == "") {
      TRUE
    } else {
      conflicts <- as.numeric(p$conflicts.version)
      actual <- as.numeric(p$conflicts.actual.version)
      eval(call(p$conflicts.constraint, actual, conflicts))
    }
  })][, list(package, conflict=conflicts)]
}

VirtualConflicts <- function(virtual, conflicts) {
  # Conflicts with virtual packages
  virtual <- virtual[, list(conflict=package, provides)]
  ## conflicts <- conflicts[conflicts.version == "",
  ##                        list(package, provides=conflicts)]
  conflicts <- conflicts[, list(package, provides=conflicts)]
  res <- merge(conflicts, virtual, by="provides")[, list(package, conflict)]
  res[package != conflict]
}

Conflicts <- function(date, version, datadir) {
  LogTime(version, date, function() {
    cudf <- readRDS(GetFilename(version, date, "rds", dirs=c(datadir, "cudf")))
    cudf <- cudf[, list(package, version, depends, provides, conflicts)]
    conflicts <- ParseConflicts(cudf)
    virtual <- ParseProvides(cudf)
    res <- rbind(DirectConflicts(cudf, conflicts),
                 VirtualConflicts(virtual, conflicts))
    unique(setkey(res, package, conflict))
  }, "Process conflicts", "process.conflicts")
}

ProcessConflicts <- function(history, datadir, cl=NULL) {
  history[, dest := GetFilename(version, date, "rds",
                                dirs=c(datadir, "conflicts"))]
  history <- history[file.exists(GetFilename(version, date, "rds",
                                             dirs=c(datadir, "cudf")))]
  ApplyHistory(history, datadir, Conflicts, cl=cl)
}

## ProcessConflicts <- function(history, datadir) {
##   src <- history[, GetFilename(version, date, "rds", dirs=c(datadir, "cudf"))]
##   dest <- history[, GetFilename(version, date, "rds",
##                                 dirs=c(datadir, "conflicts"))]
##   history <- history[file.exists(src) & !file.exists(dest), list(version, date)]
##   if (nrow(history)) {
##     invisible(by(history, 1:nrow(history), function(s) {
##       loginfo(sprintf("Processing CUDF %s %s for conflicts", s$version, s$date),
##               logger="parse.dcf")
##       dcf <- Conflicts(s$date, s$version, datadir)
##       saveRDS(dcf, GetFilename(s$version, s$date, "rds",
##                                dirs=c(datadir, "conflicts")))
##     }))
##   }
## }
