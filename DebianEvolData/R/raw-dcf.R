DownloadDCF <- function(date, link, version, datadir) {
  dest <- GetFilename(version, date, "gz", dirs=c(datadir, "dcf"))
  res <- download.file(file.path(link, "Packages.gz"),
                       dest, method="wget")
  if (res) {
    file.remove(dest)
    loginfo("Unable to download %s %s", version, date,
            logger="raw.download.dcf")
  }
  res
}

DownloadHistory <- function(version, url, datadir) {
  loginfo("Downloading list of snapshots for %s", version, logger="raw")
  history <- ListSnapshots(version, url)
  saveRDS(history, file.path(datadir, sprintf("%s.rds", version)))
  history <- history[!file.exists(GetFilename(history$version, history$date,
                                              "gz", dirs=c(datadir, "dcf"))), ]
  if (nrow(history)) {
    loginfo("Downloading %d missing snapshots for %s", nrow(history), version,
            logger="raw")
    by(history, 1:nrow(history), function(snapshot) {
      DownloadDCF(snapshot$date, snapshot$link, version, datadir)
    })
  }
}
