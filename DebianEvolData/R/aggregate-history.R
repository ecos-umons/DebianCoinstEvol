AggregateHistory <- function(version, datadir, save=TRUE) {
  LogTime(version, NA, function() {
    datadir <- file.path(datadir, "aggregate", version)
    class.size <- readRDS(file.path(datadir, "/metrics-matrix/class-size.rds"))
    conflicts.all <- readRDS(file.path(datadir, "/metrics-matrix/conflicts-all.rds"))
    history <- !is.na(conflicts.all)
    conflicts.all[!history] <- 0
    class.size[!history] <- 0
    class.size[class.size > 0] <- 1
    res <- data.table(date=rownames(history), version=version,
                      "packages"=rowSums(history), conflicts=rowSums(class.size))
    res <- cbind(res, rbindlist(apply(conflicts.all, 1, function(p) {
      data.table(one=sum(p == 1), two=sum(p == 2), three=sum(p == 3),
                 four=sum(p == 4), five=sum(p == 5), more=sum(p > 5))
    })))
    setkey(res, date)
    if (save) saveRDS(res, file.path(datadir, "metrics-history.rds"))
    res
  }, "Aggregate metrics history", "aggregate.metrics.history")
}
