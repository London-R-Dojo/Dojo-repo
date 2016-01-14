
context("test 2")
test_that("our mysumNA function doesn't work",
{
    expect_that(mysumNA(mtcars, "cyl"), equals(198))
    
    expect_that(mysumNA(mtcars, "hello"), equals(198))
    
    expect_that(mysumNA(readRDS("ss1.rds"), "cyl"), equals(64))
    expect_that(mysumNA(readRDS("ss0.rds"), "cyl"), equals(134))
    expect_that(mysumNA(readRDS("ssNA.rds"), "cyl"), equals(NA_real_))
    expect_that(mysumNA(readRDS("ssNA.rds"), "cyl"), equals(NA_real_))
    expect_is(mysumNA(readRDS("ssNA.rds"), "cyl"), "numeric")
})
