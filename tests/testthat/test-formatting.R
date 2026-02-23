# test-formatting.R

## do_format ---------------------------------------------------------------

test_that("do_format() returns a character vector the same length as x", {
  expect_type(do_format(1.23), "character")
  expect_length(do_format(1:5), 5)
})

test_that("do_format() preserves trailing zeros", {
  expect_equal(do_format(1.20),        "1.20")
  expect_equal(do_format(1.0),         "1.00")
  expect_equal(do_format(1.2, digits = 3), "1.200")
  expect_equal(do_format(1,   digits = 4), "1.0000")
})

test_that("do_format() rounds to the requested number of decimal places", {
  expect_equal(do_format(1.23456, digits = 2), "1.23")
  expect_equal(do_format(1.235,   digits = 2), "1.24")
  expect_equal(do_format(1.999,   digits = 2), "2.00")
  expect_equal(do_format(1.206,   digits = 2), "1.21")
})

test_that("do_format() works with digits = 0", {
  expect_equal(do_format(1.7, digits = 0), "2")
  expect_equal(do_format(2.3, digits = 0), "2")
})

test_that("do_format() produces no leading or trailing whitespace", {
  res <- do_format(c(1, 10, 100, 1000))
  expect_equal(res, trimws(res))
})

test_that("do_format() is not in scientific notation", {
  expect_false(any(grepl("e", do_format(c(0.0001, 1e5)))))
})

test_that("do_format() returns 'NA' for NA input", {
  expect_equal(do_format(NA_real_), "NA")
})

test_that("do_format() errors on invalid inputs", {
  expect_error(do_format("a"))
  expect_error(do_format(numeric(0)))
  expect_error(do_format(1, digits = "2"))
  expect_error(do_format(1, digits = c(2, 3)))
})


## format_estci ------------------------------------------------------------

test_that("format_estci() produces the correct string format", {
  expect_equal(format_estci(1.2, 0.8, 1.6), "1.20 (0.80 - 1.60)")
})

test_that("format_estci() respects the ci_sep argument", {
  expect_equal(format_estci(1.2, 0.8, 1.6, ci_sep = "; "), "1.20 (0.80; 1.60)")
  expect_equal(format_estci(1.2, 0.8, 1.6, ci_sep = ", "), "1.20 (0.80, 1.60)")
})

test_that("format_estci() respects the digits argument", {
  expect_equal(format_estci(1.2, 0.8, 1.6, digits = 3), "1.200 (0.800 - 1.600)")
  expect_equal(format_estci(1.2, 0.8, 1.6, digits = 0), "1 (1 - 2)")
})

test_that("format_estci() is vectorized over est, lwr, upr", {
  res <- format_estci(1:3, 0:2, 2:4)
  expect_type(res, "character")
  expect_length(res, 3)
})

test_that("format_estci() applies exp() transform when use_exp = TRUE", {
  res <- format_estci(0, -1, 1, use_exp = TRUE)
  expected <- paste0(
    do_format(exp(0)),  " (",
    do_format(exp(-1)), " - ",
    do_format(exp(1)),  ")"
  )
  expect_equal(res, expected)
})

test_that("format_estci() caps the upper limit when use_exp = TRUE and upr > upr_lim", {
  # exp(5) ≈ 148 > 100
  res <- format_estci(0, -1, 5, use_exp = TRUE, upr_lim = 100)
  expect_true(grepl(">100", res))
})

test_that("format_estci() does not cap the upper limit when use_exp = FALSE", {
  res <- format_estci(0, -1, 5, use_exp = FALSE, upr_lim = 100)
  expect_false(grepl(">100", res))
})

test_that("format_estci() does not cap when upr is below upr_lim (use_exp = TRUE)", {
  # exp(1) ≈ 2.7, well below upr_lim = 100
  res <- format_estci(0, -1, 1, use_exp = TRUE, upr_lim = 100)
  expect_false(grepl(">", res))
})

test_that("format_estci() errors on invalid inputs", {
  expect_error(format_estci("a", 0, 1))            # non-numeric est
  expect_error(format_estci(1, "b", 1))            # non-numeric lwr
  expect_error(format_estci(1, 0, "c"))            # non-numeric upr
  expect_error(format_estci(numeric(0), 0, 1))     # zero-length est
  expect_error(format_estci(1:2, 0, 1))            # length mismatch est vs lwr
  expect_error(format_estci(1, 0:1, 1))            # length mismatch est vs lwr
  expect_error(format_estci(1, 0, 1, ci_sep = 1)) # non-character ci_sep
  expect_error(format_estci(1, 0, 1, use_exp = "yes"))     # non-logical use_exp
  expect_error(format_estci(1, 0, 1, digits = c(2, 3)))    # length > 1 digits
})


## format_pval2 ------------------------------------------------------------

test_that("format_pval2() returns a character vector", {
  expect_type(format_pval2(0.05), "character")
})

test_that("format_pval2() formats p-values with nsmall trailing zeros", {
  expect_equal(format_pval2(0.034), "0.034")
  expect_equal(format_pval2(0.1),   "0.100")
  expect_equal(format_pval2(1),     "1.000")
})

test_that("format_pval2() uses threshold notation for very small p-values", {
  expect_true(startsWith(format_pval2(1e-6),          "<"))
  expect_true(startsWith(format_pval2(0, digits = 3), "<"))
  expect_true(grepl("0\\.001", format_pval2(1e-6)))
})

test_that("format_pval2() threshold respects the digits argument", {
  expect_true(startsWith(format_pval2(0.005, digits = 2), "<"))
  expect_true(grepl("0\\.01",   format_pval2(0.005, digits = 2)))
  expect_equal(format_pval2(0.034, digits = 2), "0.03")
  expect_true(startsWith(format_pval2(1e-6, digits = 4), "<"))
  expect_true(grepl("0\\.0001", format_pval2(1e-6, digits = 4)))
})

test_that("format_pval2() is vectorized", {
  res <- format_pval2(c(0.5, 0.034, 1e-6))
  expect_length(res, 3)
  expect_type(res, "character")
})

test_that("format_pval2() returns no leading or trailing whitespace", {
  res <- format_pval2(c(0.05, 1e-6, 1))
  expect_equal(res, trimws(res))
})

test_that("format_pval2() errors on invalid inputs", {
  expect_error(format_pval2("a"))
  expect_error(format_pval2(numeric(0)))
  expect_error(format_pval2(0.05, digits = c(2, 3)))
  expect_error(format_pval2(0.05, digits = "3"))
})


## get_coeftab -------------------------------------------------------------

test_that("get_coeftab() returns a data.table", {
  fm  <- lm(speed ~ dist, data = cars)
  res <- get_coeftab(fm, "dist")
  expect_s3_class(res, "data.table")
})

test_that("get_coeftab() default return has exactly est_ci and pvalue columns", {
  fm  <- lm(speed ~ dist, data = cars)
  res <- get_coeftab(fm, "dist")
  expect_named(res, c("est_ci", "pvalue"))
})

test_that("get_coeftab() return = 'all' includes est_ci, pvalue and extra columns", {
  fm  <- lm(speed ~ dist, data = cars)
  res <- get_coeftab(fm, "dist", return = "all")
  expect_true(all(c("est_ci", "pvalue") %in% names(res)))
  expect_gt(ncol(res), 2)
})

test_that("get_coeftab() returns one row per requested coefficient", {
  fm  <- lm(Ozone ~ Solar.R + Wind + Temp, data = airquality)
  res <- get_coeftab(fm, c("Solar.R", "Wind", "Temp"))
  expect_equal(nrow(res), 3)
})

test_that("get_coeftab() respects ci_sep", {
  fm  <- lm(speed ~ dist, data = cars)
  res <- get_coeftab(fm, "dist", ci_sep = "; ")
  expect_true(grepl("; ", res$est_ci))
})

test_that("get_coeftab() applies transform to estimate and CI", {
  fm      <- glm(breaks ~ tension, data = warpbreaks, family = poisson)
  res_raw <- get_coeftab(fm, "tensionM", return = "all")
  res_exp <- get_coeftab(fm, "tensionM", transform = exp, return = "all")
  expect_equal(res_exp$Estimate, exp(res_raw$Estimate))
  expect_equal(res_exp$`2.5 %`,  exp(res_raw$`2.5 %`))
  expect_equal(res_exp$`97.5 %`, exp(res_raw$`97.5 %`))
})

test_that("get_coeftab() pvalue column is formatted as a character", {
  fm  <- lm(speed ~ dist, data = cars)
  res <- get_coeftab(fm, "dist", return = "all")
  expect_type(res$pvalue, "character")
})

test_that("get_coeftab() est_ci column is formatted as a character", {
  fm  <- lm(speed ~ dist, data = cars)
  res <- get_coeftab(fm, "dist")
  expect_type(res$est_ci, "character")
})

test_that("get_coeftab() errors when coef_name is not in the model", {
  fm <- lm(speed ~ dist, data = cars)
  expect_error(get_coeftab(fm, "nonexistent"))
})

test_that("get_coeftab() errors when coef_name is not a character", {
  fm <- lm(speed ~ dist, data = cars)
  expect_error(get_coeftab(fm, 1))
})
