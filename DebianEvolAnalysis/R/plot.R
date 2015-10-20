## cb.palette <- c("#999999", "#E69F00", "#56B4E9", "#009E73",
##                 "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cb.palette <- c("#0072B2", "#D55E00", "#CC79A7", "#E69F00", "#56B4E9", "#009E73",
                "#F0E442")
## cb.palette <- col2grey(cb.palette)
gs.palette <- c("#ffffff", "#cccccc", "#999999", "#999999", "#333333", "#000000")
## cb.palette <- c("red", "blue", "dark green", "orange", "purple", "dark grey")

PlotBasicTS <- function(data, ylab="") {
  data$date <- as.POSIXct(data$date)
  if ("version" %in% colnames(data)) {
    data <- melt(data, id=c("date", "version"))
    p <- ggplot(data, aes(x=date, y=value, colour=variable,
                          group=paste(variable, version)))
  } else {
    data <- melt(data, id="date")
    p <- ggplot(data, aes(x=date, y=value, colour=variable, group=variable))
  }
  p <- p + xlab("Time") + ylab(ylab) +
    theme(axis.text.x=element_text(angle=90, hjust=1),
          panel.background=element_rect(fill='white'),
          panel.grid.major=element_line(colour="#DEDEDE"),
          panel.grid.major.x=element_blank(),
          panel.grid.minor=element_line(colour="white"))
  breaks <- seq.Date(as.Date("2005-01-01"), as.Date("2015-01-01"), by="year")
  p + scale_x_datetime(breaks=as.POSIXct(breaks), labels=date_format("%Y"),
                       limits=c(min(data$date), max(data$date)))
}

PlotTS <- function(data, ylab="", scale.luminosity=40,
                   stack=FALSE, legend=FALSE, group.title="variable",
                   greyscale=FALSE) {
  palette <- if (greyscale) gs.palette else cb.palette
  p <- PlotBasicTS(data, ylab)
  if (ncol(data) > 2) {
    if (stack) {
      p <- p + geom_area(colour="black", aes(fill=variable), position='stack')
      p + scale_fill_hue(l=scale.luminosity) +
        scale_fill_manual(name=group.title, values=palette)
    } else {
      if ("version" %in% colnames(data)) {
        p <- p + geom_line(aes(colour=variable, linetype=version))
      } else {
        p <- p + geom_line(aes(colour=variable))
      }
      if (!legend) {
        p <- p + theme(legend.position="none")
      }
      p + scale_colour_hue(l=scale.luminosity) +
        scale_colour_manual(values=palette)
    }
  } else p + geom_line(colour=palette[1]) + theme(legend.position="none")
}

PlotReleases <- function(p, releases, ypos=0) {
  p +
    geom_vline(data=releases, color="#DEDEDE",
               aes(xintercept=as.numeric(as.POSIXct(release)))) +
    geom_vline(data=releases, linetype="dashed", color="#DEDEDE",
               aes(xintercept=as.numeric(as.POSIXct(freeze)))) +
    annotate("text", as.POSIXct(releases$release), ypos, size=4,
             label=releases$version, hjust=-0.2)
}

PlotDevice <- function(FUNC, filename=NULL, format=NULL, ...) {
  if (!is.null(format)) message("Plotting ", filename, " in ", format)
  else message("Plotting ", filename)
  use.device <- !is.null(filename) && !is.null(format)
  if (use.device) get(format)(sprintf("%s.%s", filename, format), ...)
  FUNC()
  if (use.device) dev.off()
}
