# test-data.table_utils.R

## helpers -----------------------------------------------------------------

make_species_tab <- function() {
  as.data.table(iris)[, .N, Species]
}

## totpct ------------------------------------------------------------------

test_that("totpct() returns a data.table", {
  expect_s3_class(totpct(make_species_tab()), "data.table")
})

test_that("totpct() appends exactly one Total row", {
  tab <- make_species_tab()
  res <- totpct(tab)
  expect_equal(nrow(res), nrow(tab) + 1L)
})

test_that("totpct() Total row is in the name column", {
  tab <- make_species_tab()
  res <- totpct(tab)
  expect_equal(res$Species[nrow(res)], "Total")
})

test_that("totpct() Total row count equals the sum of all counts", {
  tab <- make_species_tab()
  res <- totpct(tab)
  expect_equal(res$N[nrow(res)], sum(tab$N))
})

test_that("totpct() appends a Pct column", {
  expect_true("Pct" %in% names(totpct(make_species_tab())))
})

test_that("totpct() Pct column is character", {
  res <- totpct(make_species_tab())
  expect_type(res$Pct, "character")
})

test_that("totpct() Total row Pct is '100.00'", {
  res <- totpct(make_species_tab())
  expect_equal(res$Pct[nrow(res)], "100.00")
})

test_that("totpct() individual Pct values sum to 100", {
  tab <- make_species_tab()
  res <- totpct(tab)
  row_pcts <- as.numeric(res$Pct[-nrow(res)])
  expect_equal(sum(row_pcts), 100, tolerance = 0.01)
})

test_that("totpct() respects the digits argument", {
  tab  <- make_species_tab()
  res1 <- totpct(tab, digits = 1)
  res3 <- totpct(tab, digits = 3)
  # With more digits the Total row should read "100.000" vs "100.0"
  expect_equal(res1$Pct[nrow(res1)], "100.0")
  expect_equal(res3$Pct[nrow(res3)], "100.000")
})

test_that("totpct() accepts character name_col and n_col", {
  res <- totpct(make_species_tab(), name_col = "Species", n_col = "N")
  expect_s3_class(res, "data.table")
  expect_true("Total" %in% res$Species)
})

test_that("totpct() accepts numeric name_col and n_col indices", {
  tab <- make_species_tab()
  res <- totpct(tab, name_col = 1L, n_col = 2L)
  expect_true("Total" %in% res$Species)
})

test_that("totpct() works with a 3-column table using n_col = 3", {
  tab <- as.data.table(iris)[, .(Mean = mean(Sepal.Length), .N), Species]
  res <- totpct(tab, n_col = 3L)
  expect_true("Total" %in% res$Species)
  expect_equal(res$N[nrow(res)], sum(tab$N))
})

test_that("totpct() does not modify the original table", {
  tab      <- make_species_tab()
  tab_orig <- copy(tab)
  totpct(tab)
  expect_equal(tab, tab_orig)
})

test_that("totpct() errors when ncol(tab) < 2", {
  tab <- as.data.table(data.frame(x = 1:3))
  expect_error(totpct(tab))
})

test_that("totpct() errors when name_col == n_col", {
  expect_error(totpct(make_species_tab(), name_col = 1L, n_col = 1L))
})

test_that("totpct() errors when n_col index is out of bounds", {
  expect_error(totpct(make_species_tab(), n_col = 99L))
})

test_that("totpct() errors when n_col is incorrectly named", {
  expect_error(totpct(make_species_tab(), n_col = "n"), "Cannot find variable 'n' in 'tab'")
})

test_that("totpct() errors when n_col column cannot be coerced to numeric", {
  tab <- as.data.table(data.frame(
    label = c("a", "b", "c"),
    value = c("x", "y", "z"),
    stringsAsFactors = FALSE
  ))
  expect_error(totpct(tab, name_col = 1L, n_col = 2L))
})


## show_na -----------------------------------------------------------------

test_that("show_na() returns a matrix", {
  expect_true(is.matrix(show_na(airquality)))
})

test_that("show_na() has columns NAs, n0chars, NAor0", {
  res <- show_na(airquality)
  expect_equal(colnames(res), c("NAs", "n0chars", "NAor0"))
})

test_that("show_na() has one row per column of the input", {
  res <- show_na(airquality)
  expect_equal(nrow(res), ncol(airquality))
  expect_equal(rownames(res), names(airquality))
})

test_that("show_na() correctly counts NAs in numeric columns", {
  d   <- data.frame(x = c(1, NA, 3), y = c(NA, NA, 1))
  res <- show_na(d)
  # cbind of mixed integer/double produces a list-mode matrix;
  # [[1]] extracts the scalar from the single-element list cell.
  expect_equal(res[1, "NAs"][[1]], 1L)
  expect_equal(res[2, "NAs"][[1]], 2L)
})

test_that("show_na() sets n0chars to NA for numeric columns", {
  d   <- data.frame(x = 1:3, y = 4:6)
  res <- show_na(d)
  expect_true(all(is.na(res[, "n0chars"])))
})

test_that("show_na() counts zero-length strings in character columns", {
  d   <- data.frame(x = c("a", "", "b", ""), stringsAsFactors = FALSE)
  res <- show_na(d)
  expect_equal(res["x", "n0chars"], 2)
})

test_that("show_na() NAor0 equals NAs for numeric columns", {
  d   <- data.frame(x = c(1, NA, 3))
  res <- show_na(d)
  expect_equal(res["x", "NAor0"], res["x", "NAs"])
})

test_that("show_na() NAor0 sums NAs and zero-length strings for character columns", {
  # 1 NA + 2 empty strings = 3
  d   <- data.frame(x = c("a", "", NA, "b", ""), stringsAsFactors = FALSE)
  res <- show_na(d)
  expect_equal(res["x", "NAor0"], 3)
})

test_that("show_na() returns zero NAs for a clean numeric data.frame", {
  d   <- data.frame(x = 1:3, y = 4:6)
  res <- show_na(d)
  expect_true(all(res[, "NAs"] == 0))
})

test_that("show_na() works on data.table input", {
  dt  <- as.data.table(airquality)
  res <- show_na(dt)
  expect_true(is.matrix(res))
  expect_equal(nrow(res), ncol(dt))
})

test_that("show_na() does not modify the caller's data.frame", {
  d      <- data.frame(x = c(1, NA, 3))
  d_orig <- d
  show_na(d)
  expect_equal(d, d_orig)
})
