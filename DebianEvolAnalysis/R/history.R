PlotHistoryData <- function(versions, datadir, FUNC, filename=NULL, format=NULL) {
  files <- sprintf("%s/aggregate/%s/metrics-history.rds", datadir, versions)
  data <- rbindlist(lapply(files, readRDS))
  PlotDevice(function() FUNC(data), filename, format, height=4)
}

PlotHistory <- function(versions, datadir, filename=NULL, format=NULL) {
  releases <- readRDS(file.path(datadir, "releases.rds"))
  PlotHistoryData(versions, datadir, function(data) {
    print(PlotTS(data[, list(date, version, packages, conflicts)], releases))
  }, filename, format)
}

PlotHistoryRatios <- function(versions, datadir, filename=NULL, format=NULL) {
  PlotHistoryData(versions, datadir, function(data) {
    print(PlotTS(data[, list(date, version, " "=conflicts / packages)]))
  }, filename, format)
}

PlotHistoryNumberConflicts <- function(version, datadir, filename=NULL, format=NULL) {
  data <- readRDS(sprintf("%s/aggregate/%s/metrics-history.rds", datadir, version))
  data <- data[, list(date, version, one, two, three, four, five, more)]
  total <- rowSums(data[, names(data)[-(1:2)], with=FALSE])
  data <- cbind(data[, list(date, version)],
                data[, names(data)[3:8], with=FALSE] / total)
  PlotDevice(function() {
    print(PlotTS(data[, names(data)[-2], with=FALSE], ylab="% packages",
                 stack=TRUE, group.title="# of conflicts") +
          guides(fill = guide_legend(reverse=TRUE)))
    }, sprintf("%s-%s", filename, version), format, height=4)
}

PlotHistoryConflictLifetime <- function(version, datadir, filename=NULL, format=NULL) {
  Category <- function(diff) {
    sapply(diff, function(d) {
      if (d < 7) "week"
      else if (d < 30) "month"
      else "more"
    })
  }

  releases <- readRDS(file.path(datadir, "releases.rds"))
  data <- readRDS(sprintf("%s/aggregate/%s/diff-history.rds", datadir, version))
  data <- data[!is.na(new.before) & !is.na(rem.after)]
  data <- table(strftime(data$new.before, "%Y-%m-01"),
                Category(data[, difftime(rem.after, new.before, units="days")]))
  data <- data.table(date=rownames(data), week=data[, "week"],
                     month=data[, "month"], more=data[, "more"])
  all.dates <- sapply(seq(2005, 2014), paste,
                      sprintf("%02d", seq(1, 12)), "01", sep="-")
  data <- rbind(data.table(date=setdiff(all.dates, data$date),
                           week=0, month=0, more=0), data)
  PlotDevice(function() {
    print(PlotTS(data, releases, legend=TRUE))
  }, sprintf("%s-%s", filename, version), format, height=4)
}
