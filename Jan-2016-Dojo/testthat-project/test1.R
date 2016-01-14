
context("Test 1")    # this will be printed out to know what is being tested
test_that("our mysum function doesn't work",
{
    # test our sum function on the cyl column which exists and hello column which doesn't
    expect_that(mysum(mtcars, "cyl"), equals(198))
    expect_that(mysum(mtcars, "hello"), equals(-1))
    # test our sum function on the cyl column which exists and hello column which doesn't on a data.table
    expect_that(mysum(data.table(mtcars), "cyl"), equals(198))
    expect_that(mysum(data.table(mtcars), "hello"), equals(-1))
    # thisisastring isn't a data.table or data.frame so should raise and error in the function
    expect_that(mysum("thisisastring", "hello"), equals(-1))
    # test the subsets of the mtcars data.frame which we saved earlier
    expect_that(mysum(readRDS("ss1.rds"), "cyl"), equals(64))
    expect_that(mysum(readRDS("ss0.rds"), "cyl"), equals(134))
    # test the subsets of the mtcars data.frame which has an NA appended to the end
    expect_that(mysum(readRDS("ssNA.rds"), "cyl"), equals(NA_real_))
    expect_is(mysum(readRDS("ssNA.rds"), "cyl"), "numeric")
})
