test_that("do_format works", {
  expect_equal(do_format(1.2345, 2), "1.23")
  expect_equal(do_format(1, 2), "1.00")
})

test_that("format.pval2 works", {
  expect_equal(format.pval2(0.12345, 3), "0.123")
  expect_true(grepl("<", format.pval2(1e-6)))
})

test_that("effect_ci works", {
  res <- effect_ci(1.234, 0.5, 2.5, dig = 2)
  expect_equal(res, "1.23 (0.50 - 2.50)")
})


test_that("pooled SD calculation", {
  n <- c(10, 20)
  sd <- c(2, 3)
  pooled <- get_sd_pooled(n, sd)
  expect_true(is.numeric(pooled))
  expect_gt(pooled, 0)
})

test_that("total variance works", {
  means <- c(1, 2)
  vars <- c(1, 4)
  probs <- c(0.4, 0.6)
  v <- totvar(means, vars, probs)
  expect_true(is.numeric(v))
})


test_that("get_effect extracts lm effects", {
  fit <- lm(mpg ~ wt, data = mtcars)
  res <- get_effect(fit, "wt")
  expect_true("est_ci" %in% names(res))
  expect_true("pvalue" %in% names(res))
})


test_that("standardized mean functions", {
  sm <- std_mean(20, 5, 2)
  se <- std_mean_se(20, 5, 2)
  expect_true(is.numeric(sm))
  expect_true(is.numeric(se))
  expect_gt(se, 0)
})

test_that("simple two-sample t-test works", {
  ns <- c(10, 12)
  means <- c(5, 6)
  vars <- c(4, 5)
  res <- simple.2sample.t.test(ns, means, vars)
  expect_equal(nrow(res), 2)
  expect_true(all(c("Diff", "SE", "p_value") %in% names(res)))
})


test_that("comma2numeric works", {
  x <- c("1,2", "3,4")
  expect_equal(comma2numeric(x), c(1.2, 3.4))
})

test_that("set helpers work", {
  A <- c(1, 2, 3)
  B <- c(3, 4)
  res <- show_set(A, B)
  expect_equal(res$intersect, 1)
})
