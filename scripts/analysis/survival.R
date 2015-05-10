## library(DebianEvolAnalysis)
devtools::load_all("DebianEvolAnalysis")

datadir <- "data"
versions <- c("stable", "testing")
plot.format <- NULL

for (plot.format in c("svg", "pdf")) {
  for (version in versions) {
    PlotTimeBeforeConflict(version, datadir, "images/conflicts-days-before-hist", plot.format)
    PlotConflictIntroductionBarplot(version, datadir, "images/barchart-first-conflict", plot.format)
    PlotPackageSurvival(version, datadir, "images/survival", plot.format)
    PlotConflictIntroductionSurvival(version, datadir, "images/survival", plot.format)
    PlotConflictSurvival(version, datadir, "images/survival", plot.format)
  }
}
