ComputeDiff <- function(history, conflicts) {
  rbindlist(mapply(function(before, after) {
    history.before <- history[before, ]
    history.after <- history[after, ]
    conflicts.before <- conflicts[before, ]
    conflicts.after <- conflicts[after, ]

    package.new <- colnames(history)[!history.before & history.after]
    package.rem <- colnames(history)[history.before & !history.after]
    conflict.new <- colnames(conflicts)[!conflicts.before & conflicts.after &
                                        history.after]
    conflict.rem <- colnames(conflicts)[conflicts.before & !conflicts.after &
                                        history.before]

    GetDataTable <- function(variable) {
      values <- get(variable)
      if (length(values)) {
        data.table(before=before, after=after, package=values, change=variable)
      }
    }

    rbind(GetDataTable("package.new"), GetDataTable("package.rem"),
          GetDataTable("conflict.new"), GetDataTable("conflict.rem"))
  }, rownames(history)[-nrow(history)], rownames(history)[-1], SIMPLIFY=FALSE))
}

AggregateDiffs <- function(version, datadir) {
  LogTime(version, NA, function() {
    dest <- file.path(datadir, "aggregate", version)
    conflicts <- readRDS(file.path(dest, "metrics-matrix/conflicts.rds"))
    history <- !is.na(conflicts)
    conflicts[is.na(conflicts)] <- 0
    diff <- ComputeDiff(history, conflicts)
    setkey(diff, before, after, package)
    saveRDS(diff, file.path(dest, "diff.rds"))
    diff
  }, "Aggregatings diffs", "aggregate.diffs")
}

DiffHistory <- function(diff, type="conflict") {
  conflicts <- diff[grep(type, change)]
  if (nrow(conflicts)) {
    setkey(conflicts, before, after, package)
    res <- data.table()
    ChangeType <- function(c) strsplit(c, ".", fixed=TRUE)[[1]][1]
    if (conflicts$change[1] == sprintf("%s.rem", type)) {
      tmp <- conflicts[1, list(package, new.before=NA, new.after=NA,
                               rem.before=after, rem.after=before,
                               change=ChangeType(change))]
      res <- rbind(res, tmp)
      conflicts <- conflicts[-1]
      if (nrow(conflicts) == 0) return(res)
    }
    if (conflicts[nrow(conflicts), change] == sprintf("%s.new", type)) {
      tmp <- conflicts[1, list(package, new.before=before, new.after=after,
                               rem.before=NA, rem.after=NA,
                               change=ChangeType(change))]
      res <- rbind(res, tmp)
      conflicts <- conflicts[-nrow(conflicts)]
      if (nrow(conflicts) == 0) return(res)
    }
    conflicts <- split(conflicts, sapply(1:(nrow(conflicts) / 2), rep, 2))
    tmp <- rbindlist(lapply(conflicts, function(c) {
      cbind(c[1, list(package, new.before=before, new.after=after)],
            c[2, list(rem.before=before, rem.after=after,
                      change=ChangeType(change))])
    }))
    rbind(res, tmp)
  }
}

AggregateDiffHistory <- function(version, datadir, save=TRUE) {
  LogTime(version, NA, function() {
    dest <- file.path(datadir, "aggregate", version)
    diff <- readRDS(file.path(dest, "diff.rds"))
    res <- rbindlist(lapply(split(diff, diff$package), DiffHistory))
    saveRDS(res, file.path(dest, "diff-history.rds"))
    res
  }, "Aggregate diff history", "aggregate.diffs.history")
}
