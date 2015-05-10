ListMonths <- function(url) {
  # Fetch the list of monthly archives of Debian packages
  doc = htmlTreeParse(url, useInternalNodes=TRUE)
  re <- "^\\./\\?year=(20\\d\\d)&month=(\\d\\d?)$"
  l <- grep(re, sapply(getNodeSet(doc, "//ul/li/a[@href]"),
                       function(e) xmlAttrs(e)[["href"]]), value=TRUE)
  data.table(year=as.numeric(gsub(re, "\\1", l)),
             month=as.numeric(gsub(re, "\\2", l)),
             link=file.path(url, l))
}

FetchSnapshots <- function(snapshot, url, subdir) {
  # Fetch the list of archives of Debian packages for a given month
  doc = htmlTreeParse(snapshot$link, useInternalNodes=T)
  grep(sprintf("^%d%02d\\d\\dT\\d{6}Z/", snapshot$year, snapshot$month),
       sapply(getNodeSet(doc, "//a[@href]"),
              function(e) xmlAttrs(e)[["href"]]), value=TRUE)
}

ListSnapshots <- function(version, url, area="main", arch="i386") {
  # Fetch the list of all Debian package archives.
  # version: stable, testing or unstable
  # area: main, contrib or non-free
  subdir <- sprintf("dists/%s/%s/binary-%s", version, area, arch)
  months <- ListMonths(url)
  links <- unlist(by(months, 1:nrow(months), FetchSnapshots, url, subdir))
  dates <- as.POSIXct(strptime(links, tz="Z", format="%Y%m%dT%H%M%SZ/"))
  data.table(date=as.character(dates), version=version, arch=arch, area=area,
             link=file.path(url, links, subdir),
             key=c("date", "version", "arch", "area"))
}
