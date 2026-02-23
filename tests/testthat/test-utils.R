# test-utils.R

## comma2numeric -----------------------------------------------------------

test_that("comma2numeric() converts comma-decimal strings to numeric", {
  expect_equal(comma2numeric("1,5"),              1.5)
  expect_equal(comma2numeric(c("0,5", "1,25")),   c(0.5, 1.25))
  expect_equal(comma2numeric("0,0"),              0)
  expect_equal(comma2numeric("-1,5"),             -1.5)
})

test_that("comma2numeric() returns a numeric (double) vector", {
  expect_type(comma2numeric("1,5"), "double")
})

test_that("comma2numeric() returns NA for non-numeric strings", {
  expect_true(is.na(suppressWarnings(comma2numeric("abc"))))
  expect_true(is.na(suppressWarnings(comma2numeric(""))))
})

test_that("comma2numeric() is vectorized and preserves length", {
  x   <- c("1,0", "2,5", "abc")
  res <- suppressWarnings(comma2numeric(x))
  expect_length(res, 3)
  expect_true(is.na(res[3]))
})


## rbindall / cbindall -----------------------------------------------------

test_that("rbindall() row-binds a list of matrices", {
  lst <- list(matrix(1:4, 2, 2), matrix(5:8, 2, 2))
  res <- rbindall(lst)
  expect_equal(nrow(res), 4)
  expect_equal(ncol(res), 2)
})

test_that("cbindall() column-binds a list of matrices", {
  lst <- list(matrix(1:4, 2, 2), matrix(5:8, 2, 2))
  res <- cbindall(lst)
  expect_equal(nrow(res), 2)
  expect_equal(ncol(res), 4)
})

test_that("rbindall() is equivalent to do.call(rbind, lst)", {
  lst <- lapply(1:3, function(i) data.frame(x = i, y = i ^ 2))
  expect_equal(rbindall(lst), do.call(rbind, lst))
})

test_that("cbindall() is equivalent to do.call(cbind, lst)", {
  lst <- lapply(1:3, function(i) matrix(i, nrow = 2))
  expect_equal(cbindall(lst), do.call(cbind, lst))
})


## rm.na -------------------------------------------------------------------

test_that("rm.na() removes NA values from a numeric vector", {
  expect_equal(rm.na(c(1, NA, 2, NA, 3)), c(1, 2, 3))
})

test_that("rm.na() returns an empty vector when all elements are NA", {
  expect_length(rm.na(c(NA_real_, NA_real_)), 0)
})

test_that("rm.na() is a no-op when the input has no NAs", {
  expect_equal(rm.na(1:5), 1:5)
})

test_that("rm.na() works on character vectors", {
  expect_equal(rm.na(c("a", NA, "b")), c("a", "b"))
})

test_that("rm.na() works on logical vectors", {
  expect_equal(rm.na(c(TRUE, NA, FALSE)), c(TRUE, FALSE))
})


## first / last ------------------------------------------------------------

set.seed(12345)
x <- rnorm(5)

test_that("first() and last() return the correct elements", {
  expect_equal(first(x), x[1])
  expect_equal(last(x),  x[length(x)])
})

test_that("first() and last() return a length-1 result", {
  expect_length(first(1:5), 1)
  expect_length(last(1:5),  1)
})

test_that("first() and last() agree on a length-1 vector", {
  expect_equal(first(42), last(42))
})

test_that("first() and last() preserve the type of the input", {
  expect_type(first(c("a", "b")), "character")
  expect_type(last(c(TRUE, FALSE)), "logical")
})


## show_set ----------------------------------------------------------------

test_that("show_set() returns a data.frame with the correct columns", {
  res <- show_set(1:5, 3:7)
  expect_s3_class(res, "data.frame")
  expect_named(res, c("nA", "nB", "uniqueA", "uniqueB",
                      "union", "intersect", "AnotB", "BnotA"))
})

test_that("show_set() nA and nB reflect the raw input lengths", {
  res <- show_set(c(1, 1, 2), c(3, 3, 4))
  expect_equal(res$nA, 3)
  expect_equal(res$nB, 3)
})

test_that("show_set() deduplicates A and B when unique = TRUE", {
  res <- show_set(c(1, 1, 2), c(2, 3, 3), unique = TRUE)
  expect_equal(res$uniqueA, 2)   # {1, 2}
  expect_equal(res$uniqueB, 2)   # {2, 3}
  expect_equal(res$intersect, 1) # {2}
})

test_that("show_set() does not deduplicate when unique = FALSE", {
  res <- show_set(c(1, 1, 2), 3:5, unique = FALSE)
  expect_equal(res$uniqueA, 3)   # no deduplication: 3 elements
})

test_that("show_set() gives correct set arithmetic for disjoint sets", {
  res <- show_set(1:3, 4:6)
  expect_equal(res$intersect, 0)
  expect_equal(res$union,     6)
  expect_equal(res$AnotB,     3)
  expect_equal(res$BnotA,     3)
})

test_that("show_set() gives correct set arithmetic for identical sets", {
  res <- show_set(1:4, 1:4)
  expect_equal(res$intersect, 4)
  expect_equal(res$union,     4)
  expect_equal(res$AnotB,     0)
  expect_equal(res$BnotA,     0)
})

test_that("show_set() gives correct set arithmetic for partial overlap", {
  # A = {1,2,3}, B = {2,3,4}: overlap = {2,3}
  res <- show_set(1:3, 2:4)
  expect_equal(res$intersect, 2)
  expect_equal(res$union,     4)
  expect_equal(res$AnotB,     1)
  expect_equal(res$BnotA,     1)
})

test_that("show_set() errors on an invalid unique argument", {
  expect_error(show_set(1:3, 1:3, unique = "yes"))
  expect_error(show_set(1:3, 1:3, unique = c(TRUE, FALSE)))
})
