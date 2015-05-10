AggregatePackages <- function(history, datadir, save=TRUE) {
  version <- unique(history$version)
  files <- history[, GetFilename(version, date, "rds",
                                 dirs=c(datadir, "strong-conflicts"))]
  packages <- character(0)
  for (f in files[file.exists(files)]) {
    loginfo(sprintf("Aggregating packages from %s", f),
            logger="aggregate.details.packages")
    packages <- union(packages, readRDS(f)$package)
  }
  if (save)
    saveRDS(packages, file.path(datadir, "aggregate", version, "packages.rds"))
  packages
}

AggregatePackageMetrics <- function(version, datadir, save=TRUE) {
  LogTime(version, NA, function() {
    datadir <- file.path(datadir, "aggregate", version)
    conflicts <- readRDS(file.path(datadir, "metrics-matrix/conflicts-all.rds"))
    history <- !is.na(conflicts)
    conflicts <- conflicts[, history[nrow(history), ]]
    history <- history[, history[nrow(history), ]]
    conflicts[!history] <- 0
    first <- apply(history, 2, function(c) min(names(c)[c]))
    first.conflict <- apply(conflicts, 2, function(c) min(names(c)[c > 0]))
    lifetime <- difftime(max(rownames(history)), first, units="days")
    duplicates <- duplicated(strftime(rownames(history), "%Y-%m-%d"))
    existing <- colSums(history[!duplicates, ])
    conflicting <- colSums(conflicts[!duplicates, ] > 0)
    res <- data.table(version=version, package=colnames(history),
                      first=first, first.conflict=first.conflict,
                      lifetime=lifetime, existing=existing,
                      conflicting=conflicting)
    if (save) saveRDS(res, file.path(datadir, "package-metrics.rds"))
    res
  }, "Aggregate package metrics", "aggregate.packages.metrics")
}
