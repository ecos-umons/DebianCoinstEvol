RemoveDummyNodes <- function(g) {
  fake.nodes <- as.integer(V(g)[V(g)$name == ""])
  if (length(fake.nodes)) {
    real.nodes <- as.integer(V(g)[V(g)$name != ""])
    from <- neighborhood(g, 1, fake.nodes, mode="in")
    to <- neighborhood(g, 1, fake.nodes, mode="out")
    new.edges <- rbindlist(lapply(1:length(fake.nodes), function(i) {
      from <- from[[i]]
      to <- to[[i]]
      node <- fake.nodes[i]
      data.table(from=from[from != node], to=to[to != node])
    }))
    induced.subgraph(g + edges(t(new.edges)), real.nodes)
  } else g
}

Dependencies <- function(date, version, datadir) {
  LogTime(version, date, function() {
    filename <- GetFilename(version, date, "rds", dirs=c(datadir, "deps"))
    g <- RemoveDummyNodes(readRDS(filename))
    packages <- V(g)$name
    direct <- neighborhood(g, 1, mode="out")
    indirect <- neighborhood(g, length(V(g)), mode="out")
    res <- rbindlist(mapply(function(direct, indirect) {
      if (length(direct) > 1) {
        package <- packages[direct[1]]
        indirect <- setdiff(indirect, direct)
        direct <- setdiff(direct, package)
        deps <- packages[c(direct, indirect)]
        types <- c(rep("direct", length(direct)),
                   rep("indirect", length(indirect)))
        data.table(package=package, dependency=deps, type=types)
      }
    }, direct, indirect, SIMPLIFY=FALSE))
    setkey(res, package, dependency)
  }, "Process dependencies", "process.deps")
}

ProcessDependencies <- function(history, datadir, cl=NULL) {
  history[, dest := GetFilename(version, date, "rds",
                                dirs=c(datadir, "deps-list"))]
  history <- history[file.exists(GetFilename(version, date, "rds",
                                             dirs=c(datadir, "deps")))]
  ApplyHistory(history, datadir, Dependencies, cl=cl)
}
