GetFilename <- function(version, date, extension,
                        prefix="", suffix="", dirs=".") {
  # Returns filename of Debian packages history snapshots
  date <- strftime(date, "%Y%m%d-%H%M%S", tz="Z")
  filename <- sprintf("%s/%s%s%s.%s", version, prefix, date, suffix, extension)
  file.path(do.call(file.path, as.list(dirs)), filename)
}

StripExtension <- function(filename) {
  # Removes the last extension of a filename
  sub("\\.[^.]+$", "", filename)
}

ReplaceExtension <- function(filename, extension) {
  # Replace the extension of a filename
  sprintf("%s.%s", StripExtension(filename), extension)
}

ApplyHistory <- function(history, datadir, FUNC, cl=NULL) {
  if (!"dest" %in% names(history)) {
    history$dest <- ""
  }
  history <- history[!file.exists(dest), list(version, date, dest)]
  if (nrow(history)) {
    if (is.null(cl)) {
      by(history, 1:nrow(history), function(s) {
        res <- FUNC(s$date, s$version, datadir)
        if (s$dest != "") saveRDS(res, s$dest)
        else res
      })
    } else {
      clusterMap(cl, function(date, version, datadir, dest) {
        res <- FUNC(date, version, datadir)
        if (dest != "") saveRDS(res, dest)
        else res
      }, history$date, history$version, datadir, history$dest)
    }
  }
}

LogTime <- function(version, date, FUNC, msg, logger, value=TRUE, ...) {
  if (!is.na(date)) msg <- sprintf("%s %s %s", msg, version, date)
  else msg <- sprintf("%s %s", msg, version)
  loginfo(msg, logger=logger)
  t <- system.time(res <- FUNC(...))
  loginfo("Time %s: %.2f", msg, t[3], logger=logger)
  if (value) res else t
}
