ReadDCF <- function(date, version, datadir) {
  LogTime(version, date, function() {
    fields <- c("date", "Package", "Version", "Installed.Size",
                "Maintainer", "Architecture", "Depends", "Pre.Depends",
                "Description", "Homepage", "Tag", "Section", "Priority",
                "Filename", "Size", "MD5sum", "SHA1", "SHA256",
                "Source", "Suggests", "Recommends", "Multi.Arch",
                "Provides", "Replaces", "Conflicts", "Enhances",
                "Breaks")
    dcf <- read.dcf(GetFilename(version, date, "gz", dirs=c(datadir, "dcf")))
    dcf <- data.table(data.frame(dcf, stringsAsFactors=FALSE))
    dcf <- dcf[, intersect(colnames(dcf), fields), with=FALSE]
    setnames(dcf, colnames(dcf), tolower(colnames(dcf)))
    ## melt(dcf, "package", na.rm=TRUE)
  }, "Parse DCF", "parse.dcf")
}

ConvertDCF <- function(history, datadir, cl=NULL) {
  history[, dest := GetFilename(version, date, "rds", dirs=c(datadir, "dcf"))]
  history <- history[file.exists(ReplaceExtension(dest, "gz"))]
  ApplyHistory(history, datadir, ReadDCF, cl=cl)
}

## ConvertDCF <- function(history, datadir) {
##   dest <- history[, GetFilename(version, date, "rds", dirs=c(datadir, "dcf"))]
##   for (dest in dest[!file.exists(dest)]) {
##     src <- ReplaceExtension(dest, "gz")
##     loginfo(sprintf("Parsing %s", src), logger="parse.dcf")
##     dcf <- ReadDCF(src)
##     saveRDS(dcf, dest)
##   }
## }

## DCastDCF <- function(dcf) {
##   dcast.data.table(dcf, package ~ variable, fun.aggregate=function(s) {
##     if (length(s) == 0) {
##       ""
##     } else {
##       s[1]
##     }
##   })
## }
