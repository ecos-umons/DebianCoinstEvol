\name{RunData}
\alias{RunData}
\alias{RawData}
\alias{ParseData}
\alias{ProcessData}
\alias{AggregateData}
\encoding{UTF-8}
\title{Run data extraction and processing functions}
\description{
  Reads a Debian Control File using R built-in read.dcf and melt it
  using reshape2 into a data.table.
}

\usage{
RawData(versions, url="http://snapshot.debian.org/archive/debian/",
       datadir="data", logdir="log", n=6, download=TRUE, run.tools=TRUE,
       filter.coinst=NULL)
ParseData(versions, datadir="data", logdir="log", n=4)
ProcessData(versions, datadir="data", logdir="log", n=6)
AggregateData(versions, datadir="data", logdir="log")
}
\arguments{
  \item{versions}{Versions of Debian to download (combination of stable,
    testing and unstable)}
  \item{url}{Debian website url}
  \item{datadir}{Root directory where to store data}
  \item{logdir}{Directory where to write logging}
  \item{n}{Number of process to use for parallelism}
  \item{download}{Whether to download new available snapshots or not}
  \item{run.tools}{Whether to run tools on downloaded snapshots or not}
  \item{filter.coinst}{If not NULL and is a parsable date, it will be
    used to only run coinst on dates after it.}
}
\details{
  \code{RawData} downloads snapshots of lists of packages (Debian
  Control Files) for the i386 architecture from debian website. It also
  runs tools (ceve and coinst) to get CUDF files, GraphML dependency
  graph and results from coinst. DCF files will be stored in
  datadir/dcf, cudf to datadir/cudf, GraphML graphs to datadir/deps and
  coinst results to datadir/coinst.

  \code{ParseData} parses raw data files obtained by \code{RawData}.

  \code{ProcessData} process the parsed data files. It will generate
  list of conflicts between packages in datadir/conflicts, list of
  strong conflicts in datadir/strong-conflicts and list of dependencies
  in datadir/deps-list.

  \code{AggregateData} generate aggregation of the data. It will
  populate data/aggregate directory with aggregated list of packages and
  conflicts from all the snapshot history.
}

\author{
  Maëlick Claes <himself@maelick.net>
}

\keyword{debian}
\keyword{data}
