# Replication package for MSR 2015

We provide here the information necessary to replicate the historical
analysis of coinstallability issues in the Debian distribution
described in the article *A historical analysis of Debian package
incompatibilities* by Maelick Claes, Tom Mens, Roberto Di Cosmo and
Jérôme Vouillon.

This information consists of the code and scripts used to retrieve and
analyse the historical information from the
[snapshot.debian.net](http://snapshot.debian.net) archive.

The instruction provided here are intended for execution on a *nix
system, especially a GNU/Linux based one, and preferentially a Debian
based one, where the prerequisite tools are pre-packaged.

## Prerequisites

Install or compile
[the *coinst* tool](https://github.com/vouillon/coinst), which is
[described elsewhere](http://coinst.irill.org). On a debian system,
just issue the command

```bash
apt-get install coinst
```

Also install the statistical [R](http://r-project.org) environment. On
a Debian based system a recent installation of R may be required. To
fulfill this purpose one can use one of the additional
[package repository](http://cran.r-project.org/bin/linux/debian/).
Then issue the command

```bash
apt-get install r-base
```

Finally a few R package are also required. After running R itself one
can install them as:

```R
install.packages("data.table", "logging", "XML", "reshape2",
"stringr", "rjson", "igraph", "parallel", "ggplot2", "survival",
"directlabels", "scales", "devtools")
```

Note that it might require a few additional Debian package like
libxml2-dev.

Finally installing the two packages can be done using the bash
command:

```bash
R CMD INSTALL DebianEvolData
R CMD INSTALL DebianEvolAnalysis
```

## Step 1: retrieve and process the historical data

First make sure there is a "data" folder where scripts will be run.
Then run data retrieval script with Rscript:

```bash
mkdir -p data
Rscript scripts/data/raw.R
Rscript scripts/data/parse.R
Rscript scripts/data/process.R
Rscript scripts/data/aggregate.R
```

Note that this will require to have enough disk space to store raw
and processed data. It can amount to more than 1To of data. It may
also require a lot of memory, in particular for the aggregate data
step. By default most operations will be run in parallel on 2, 4 or 6
processes. If you have less than 6 cores you can adjust the number of
process to use in the scripts. Using a lot of cores may also require
you to have more memory.

## Step 2: perform the statistical analysis

To avoid having to run data retrieval and processing step, we provide
the required aggregated data sets as R serialized data.table objects.

Make sure an "images" folder exists then run the analysis which will
generate svg and pdf plots in this folder:

```bash
mkdir -p images
Rscript scripts/analysis/history.R
Rscript scripts/analysis/survival.R
```
