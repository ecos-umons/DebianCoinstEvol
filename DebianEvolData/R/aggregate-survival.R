AggregatePackageSurvival <- function(version, datadir, save=TRUE) {
  LogTime(version, NA, function() {
    datadir <- file.path(datadir, "aggregate", version)
    conflicts <- readRDS(file.path(datadir, "/metrics-matrix/conflicts-all.rds"))
    history <- !is.na(conflicts)
    conflicts[is.na(conflicts)] <- 0
    res <- data.table(package=colnames(history))
    res$no.conflicts <- colSums(conflicts) == 0
    res$always.conflicts <- colSums(history == (conflicts > 0)) == nrow(history)

    minmax <- sapply(1:ncol(history), function(i) {
      res <- conflicts[history[, i], i]
      if (length(res)) c(min(res), max(res)) else c(0, 0)
    })
    res$min <- minmax[1, ]
    res$max <- minmax[2, ]

    firstlast <- apply(history, 2, function(c) {
      res <- names(c)[c]
      c(min(res), max(res))
    })
    res$first <- firstlast[1, ]
    res$last <- firstlast[2, ]

    firstlast <- apply(conflicts, 2, function(c) {
      res <- names(c)[c > 0]
      if (length(res)) c(min(res), max(res)) else rep(NA_character_, 2)
    })
    res$first.conflict <- firstlast[1, ]
    res$last.conflict <- firstlast[2, ]

    res[, lifetime := as.numeric(difftime(last, first, units="days"))]
    res[, clifetime := as.numeric(difftime(last.conflict, first.conflict, units="days"))]

    if (save) saveRDS(res, file.path(datadir, "package-survival.rds"))
    res
  }, "Aggregate package survival data", "aggregate.survival.packages")
}
