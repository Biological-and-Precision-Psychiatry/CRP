
context("testing namedList")

set.seed(12345)
x <- rnorm(5)

test_that("first() and last() work", {

  expect_equal(first(x), x[1])

  expect_equal(last(x), x[5L])

})
