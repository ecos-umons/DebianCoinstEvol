ParseCoinst <- function(date, version, datadir) {
  LogTime(version, date, function() {
    dest <- GetFilename(version, date, "rds", dirs=c(datadir, "coinst"))
    src <- GetFilename(version, date, "json", dirs=c(datadir, "coinst"))
    coinst <- fromJSON(file=src)
    classes <- setkey(unique(rbindlist(lapply(coinst$classes, function(c) {
      data.table(class=c[[1]], package=c[[2]])
    }))), package)
    incomp <- rbindlist(lapply(coinst$incompatibilities, function(i) {
      res <- expand.grid(i, i, stringsAsFactors=FALSE)
      data.table(x=res[[1]], y=res[[2]])[x != y]
    }))
    list(classes=classes, incompatibilities=incomp)
  }, "Parse coinst JSON", "parse.coinst")
}

ConvertCoinst <- function(history, datadir, cl=NULL) {
  history[, dest := GetFilename(version, date, "rds", dirs=c(datadir, "coinst"))]
  history <- history[file.exists(ReplaceExtension(dest, "json")) &
                     file.exists(GetFilename(version, date, "rds",
                                             dirs=c(datadir, "dcf")))]
  history <- history[file.exists(ReplaceExtension(dest, "json"))]
  ApplyHistory(history, datadir, ParseCoinst, cl=cl)
}
