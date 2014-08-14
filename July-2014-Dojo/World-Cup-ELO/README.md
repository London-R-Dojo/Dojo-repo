World Cup ELO ratings
=====================

Source `run.r` from within an R session:

```r
source("run.r")
```

Note: `matches.csv` must be in the working directory of the R process.

The working directory can be set/got using `setwd()`/`getwd()`.

After it has finished running:
* `matches` contains the original data set
* `frame` contains the processed data set
* `ratings` contains the final team ratings (ordered by rating)

Data set: https://github.com/mneedham/neo4j-worldcup/blob/master/data/matches.csv

Rating system: http://eloratings.net/system.html

