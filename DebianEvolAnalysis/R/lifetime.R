PlotLifetimeHist <- function(version, datadir, filename=NULL, format=NULL) {
  data <- readRDS(sprintf("data/aggregate/%s/package-metrics.rds", version))
  PlotDevice(function() {
    print(qplot(data[, as.numeric(lifetime) / 365],
                xlab="Years", ylab="# Packages") +
          theme(panel.background=element_rect(fill='white'),
                panel.grid.major=element_line(colour="#DEDEDE"),
                panel.grid.minor=element_line(colour="white")))
  }, sprintf("%s-%s", filename, version), format, height=4)
}

PlotPercentageConflictsHist <- function(version, datadir,
                                        filename=NULL, format=NULL) {
  data <- readRDS(sprintf("data/aggregate/%s/package-metrics.rds", version))
  PlotDevice(function() {
    print(qplot(data[conflicting > 0, conflicting / existing],
                xlab="Percentage of conflicting days", ylab="# Packages") +
          theme(panel.background=element_rect(fill='white'),
                panel.grid.major=element_line(colour="#DEDEDE"),
                panel.grid.minor=element_line(colour="white")))
  }, sprintf("%s-%s", filename, version), format, height=4)
}

PlotLifetimeHistAlwaysConflicts <- function(version, datadir,
                                            filename=NULL, format=NULL) {
  data <- readRDS(sprintf("data/aggregate/%s/package-metrics.rds", version))
  PlotDevice(function() {
    print(qplot(data[conflicting / existing > 0.99, as.numeric(lifetime) / 365],
                xlab="Years", ylab="# Packages") +
          theme(panel.background=element_rect(fill='white'),
                panel.grid.major=element_line(colour="#DEDEDE"),
                panel.grid.minor=element_line(colour="white")))
  }, sprintf("%s-%s", filename, version), format, height=4)
}
