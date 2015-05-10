## library(DebianEvolAnalysis)
devtools::load_all("DebianEvolAnalysis")

datadir <- "data"
versions <- c("stable", "testing")
plot.format <- NULL

for (plot.format in c("svg", "pdf")) {
  PlotHistory(versions, datadir, "images/history", plot.format)
  PlotHistoryRatios(versions, datadir, "images/history-ratio", plot.format)
  for (version in versions) {
    filename <- "images/history-num-conflicts"
    PlotHistoryNumberConflicts(version, datadir, filename, plot.format)
    filename <- "images/lifetime-hist"
    PlotLifetimeHist(version, datadir, filename, plot.format)
    filename <- "images/conflicts-perc-hist"
    PlotPercentageConflictsHist(version, datadir, filename, plot.format)
    filename <- "images/lifetime-hist-always-conflicts"
    PlotLifetimeHistAlwaysConflicts(version, datadir, filename, plot.format)
  }
  filename <- "images/history-conflict-lifetime"
  PlotHistoryConflictLifetime("testing", datadir, filename, plot.format)
}
