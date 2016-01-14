
mysum <- function(dat, col.name) {
    
    result = tryCatch({
        if ("data.table" %in% class(dat)) {
            sum(dat[ , col.name, with = FALSE])
        } else {
            sum(dat[ ,col.name])
        }
    }, warning = function(w) {
        print("there was a warning!!!")
        0
    }, error = function(e) {
        print(paste(e, "there was an error trapped in our mysum function!!!"))
        -1    
    })
    result
}

mysumNA <- function(dat, col.name) {
    #testthat::expect_that(class(dat), equals("data.frame"))
    sum(dat[ ,col.name],na.rm=T)
}

