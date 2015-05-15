PlotTimeBeforeConflict <- function(version, datadir, filename=NULL,
                                   format=NULL) {
  file <- sprintf("%s/aggregate/%s/package-survival.rds", datadir, version)
  data <- readRDS(file)[first != min(first) & !is.na(first.conflict) &
                            first != first.conflict,
                            difftime(first.conflict, first, units="days")]
  PlotDevice(function() {
    print(qplot(as.numeric(data), xlab="", ylab="") +
          theme(panel.background=element_rect(fill='white'),
                panel.grid.major=element_line(colour="#DEDEDE"),
                panel.grid.minor=element_line(colour="white")))
  }, sprintf("%s-%s", filename, version), format, height=4)
}

PlotConflictIntroductionBarplot <- function(version, datadir, filename=NULL,
                                            format=NULL) {
  file <- sprintf("%s/aggregate/%s/package-survival.rds", datadir, version)
  data <- readRDS(file)[first != min(first)]
  data <- data[, mapply(function(first, first.conflict) {
    if (is.na(first.conflict)) "Never"
    else if (first == first.conflict) "Upon introduction"
    else "After introduction"
  }, first, first.conflict)]
  levels <- c("Never", "Upon introduction", "After introduction")
  data <- data.table(x=factor(data, levels=levels))
  PlotDevice(function() {
    print(ggplot(data, aes(x=x, fill=x)) +
          geom_bar() + scale_fill_manual(values=cb.palette) + ylab("# Packages") +
          theme(axis.title.x=element_blank(), legend.position="none"))
  }, sprintf("%s-%s", filename, version), format, height=4)
}

PackageSurvival <- function(data) {
  death <- data[, last != max(last)]
  t <- data[, difftime(last, first, units="days")] / 365
  Surv(as.numeric(t), death)
}

PlotPackageSurvival <- function(version, datadir, filename=NULL, format=NULL) {
  file <- sprintf("%s/aggregate/%s/package-survival.rds", datadir, version)
  data <- readRDS(file)
  surv <- PackageSurvival(data)

  PlotDevice(function() {
    plot(survfit(surv ~ data$no.conflicts), col=c("red", "green"))
    legend(7, 1, c("Conflicts", "No conflict"), lty=1, col=c("red", "green"))
  }, sprintf("%s-noconflict-%s", filename, version), format, height=4)

  PlotDevice(function() {
    plot(survfit(surv ~ data$always.conflicts), col=c("green", "red"))
    legend(7, 1, c("Occasionnally", "Always"), lty=1, col=c("green", "red"))
  }, sprintf("%s-always-%s", filename, version), format, height=4)

  PlotDevice(function() {
    plot(survfit(surv ~ data[, first == first.conflict]), col=c("green", "red"))
    legend(7, 1, c("After", "Introduction"), lty=1, col=c("green", "red"))
  }, sprintf("%s-firstday-%s", filename, version), format, height=4)

  list(data, surv)
}

ConflictIntroductionSurvival <- function(data) {
  data <- data[is.na(first.conflict) | first.conflict != first]
  death <- !is.na(data$first.conflict)
  t <- data$last
  t[death] <- data[death, first.conflict]
  t <- difftime(t, data$first, units="days") / 365
  Surv(as.numeric(t), death)
}

PlotConflictIntroductionSurvival <- function(version, datadir, filename=NULL, format=NULL) {
  file <- sprintf("%s/aggregate/%s/package-survival.rds", datadir, version)
  data <- readRDS(file)
  surv <- ConflictIntroductionSurvival(data)
  PlotDevice(function() {
    plot(survfit(surv ~ 1), conf.int=FALSE)
  }, sprintf("%s-conflict-introduction-%s", filename, version), format, height=4)
  list(data, surv)
}

ConflictSurvival <- function(data, last.date) {
  rem <- data$rem.after
  new <- data$new.before
  death <- !is.na(rem)
  rem[is.na(rem)] <- last.date
  t <- difftime(rem, new, units="days") / 365.
  Surv(as.numeric(t), death)
}

PlotConflictSurvival <- function(version, datadir, filename=NULL, format=NULL) {
  dates <- as.character(readRDS(sprintf("%s/%s.rds", datadir, version))$date)
  conflicts <- readRDS(sprintf("%s/aggregate/%s/diff-history.rds", datadir, version))
  packages <- readRDS(sprintf("%s/aggregate/%s/package-survival.rds", datadir, version))
  data <- merge(conflicts, packages[, list(package, first)], by="package")
  surv <- ConflictSurvival(data, max(dates))
  PlotDevice(function() {
    plot(survfit(surv ~ data[, new.after == first]), mark.time=FALSE, col=c("green", "red"))
    legend(7, 1, c("After package introduction", "Upon package introduction"), lty=1, col=c("green", "red"))
  }, sprintf("%s-conflict-removal-%s", filename, version), format, height=4)
  list(data, surv)
}
