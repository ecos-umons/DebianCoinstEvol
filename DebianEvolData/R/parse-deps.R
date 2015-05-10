DependencyGraph <- function(date, version, datadir) {
  LogTime(version, date, function() {
    filename <- GetFilename(version, date, "graphml.gz", dirs=c(datadir, "deps"))
    tempfile <- tempfile()
    system2("gunzip", c("-k", "-c", filename), stdout=tempfile)
    g <- read.graph(tempfile, format="graphml")
    file.remove(tempfile)
    V(g)$name <- V(g)$package
    E(g)$weight <- 1
    V(g)$dummy.node <- V(g)$name == ""
    dummy.nodes <- as.integer(V(g)[V(g)$dummy.node])
    E(g)[get.edges(g, E(g))[, 2] %in% dummy.nodes]$weight <- 0
    g
  }, "Parse dependencies", "parse.deps")
}

ConvertDependencies <- function(history, datadir, cl=NULL) {
  history[, dest := GetFilename(version, date, "rds", dirs=c(datadir, "deps"))]
  history <- history[file.exists(ReplaceExtension(dest, "graphml.gz"))]
  ApplyHistory(history, datadir, DependencyGraph, cl=cl)
}
