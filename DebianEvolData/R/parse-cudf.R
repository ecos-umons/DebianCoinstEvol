ReadCUDF <- function(date, version, datadir) {
  LogTime(version, date, function() {
    cudf <- read.dcf(GetFilename(version, date, "cudf.gz",
                                 dirs=c(datadir, "cudf")))
    if (nrow(cudf)) {
      data.table(cudf[-c(1, nrow(cudf)),
                      !colnames(cudf) %in% c("preamble", "property", "request")],
                 key=c("package", "version"))
    } else data.table()
  }, "Parse CUDF", "parse.cudf")
}

ConvertCUDF <- function(history, datadir, cl=NULL) {
  history[, dest := GetFilename(version, date, "rds", dirs=c(datadir, "cudf"))]
  history <- history[file.exists(ReplaceExtension(dest, "cudf.gz"))]
  ApplyHistory(history, datadir, ReadCUDF, cl=cl)
}
