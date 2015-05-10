AggregateMetrics <- function(history, metric.type, datadir, save=TRUE) {
  # metrics.type is either class.size, conflicts or conflicts.all
  version <- unique(history$version)
  files <- history[, GetFilename(version, date, "rds", dirs=c(datadir, "strong-conflicts"))]
  history <- history[file.exists(files)]
  files <- files[file.exists(files)]
  version <- history$version[1]
  packages <- readRDS(file.path(datadir, "aggregate", version, "packages.rds"))
  res <- sapply(files, function(f) {
    loginfo(sprintf("Aggregating metrics %s from %s", metric.type, f),
            logger="aggregate.details.metrics")
    metrics <- readRDS(f)
    metrics <- setkey(metrics[!is.na(class), list(size=.N), by="class"],
                      class)[metrics]
    metrics[is.na(size), size := 0]
    res <- setkey(metrics[, list(conflicts.all=sum(conflicts.all),
                                 conflicts=sum(conflicts),
                                 class.size=sum(size)),
                          by="package"], package)
    res[packages][, gsub("-", ".", metric.type), with=FALSE]
  })
  res <- t(as.data.frame(res))
  rownames(res) <- history$date
  colnames(res) <- packages
  if (save)
    saveRDS(res, file.path(datadir, "aggregate", version,
                           sprintf("metrics-matrix/%s.rds", metric.type)))
  res
}

AggregateMatrices <- function(version, datadir) {
  history <- readRDS(file.path(datadir, sprintf("%s.rds", version)))
  LogTime(version, NA, AggregatePackages, "Aggregate packages",
          "aggregate.packages", value=FALSE, history, datadir)
  LogTime(version, NA, AggregateMetrics,
          "Aggregate conflict classes size", "aggregate.metrics.matrix",
          value=FALSE, history, "class.size", datadir)
  LogTime(version, NA, AggregateMetrics,
          "Aggregate conflict", "aggregate.metrics.matrix",
          value=FALSE, history, "conflicts", datadir)
  LogTime(version, NA, AggregateMetrics,
          "Aggregate conflicts (all)", "aggregate.metrics.matrix",
          value=FALSE, history, "conflicts-all", datadir)
}
