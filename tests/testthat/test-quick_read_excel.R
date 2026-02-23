# test-quick_read_excel.R

xls_path  <- system.file("extdata", "clippy.xls",  package = "readxl", mustWork = TRUE)
xlsx_path <- system.file("extdata", "clippy.xlsx", package = "readxl", mustWork = TRUE)

## return value ------------------------------------------------------------

test_that("quick_read_excel() reads an xls file and returns a tibble", {
  res <- quick_read_excel(xls_path)
  expect_s3_class(res, "tbl_df")
  expect_gt(nrow(res), 0)
})

test_that("quick_read_excel() reads an xlsx file and returns a tibble", {
  res <- quick_read_excel(xlsx_path)
  expect_s3_class(res, "tbl_df")
  expect_gt(nrow(res), 0)
})

test_that("quick_read_excel() result is identical to readxl::read_excel()", {
  expected <- readxl::read_excel(xlsx_path)
  result   <- quick_read_excel(xlsx_path)
  expect_equal(result, expected)
})

## arguments pass-through --------------------------------------------------

test_that("quick_read_excel() respects the sheet argument", {
  # clippy has two sheets; reading sheet 2 gives different dimensions
  res1 <- quick_read_excel(xlsx_path, sheet = 1)
  res2 <- quick_read_excel(xlsx_path, sheet = 2)
  # They should differ in at least one dimension
  expect_false(identical(res1, res2))
})

test_that("quick_read_excel() respects the n_max argument", {
  full <- quick_read_excel(xlsx_path)
  trunc <- quick_read_excel(xlsx_path, n_max = 1)
  expect_equal(nrow(trunc), 1)
  expect_lt(nrow(trunc), nrow(full))
})

test_that("quick_read_excel() respects the col_names = FALSE argument", {
  res <- quick_read_excel(xlsx_path, col_names = FALSE)
  # When col_names = FALSE the first row of data becomes a data row
  full <- quick_read_excel(xlsx_path, col_names = TRUE)
  expect_equal(nrow(res), nrow(full) + 1L)
})

## error handling ----------------------------------------------------------

test_that("quick_read_excel() errors with a clear message for a missing file", {
  expect_error(
    quick_read_excel("this_file_does_not_exist.xlsx"),
    "'path' does not exist"
  )
})

test_that("quick_read_excel() errors if copy_to_temp() fails", {
  with_mocked_bindings(
    copy_to_temp = function(...) FALSE,
    {
      expect_error(quick_read_excel(xlsx_path),
                   "Failed to copy 'path' to a temporary file.")
    })
})

## temp file cleanup -------------------------------------------------------

test_that("quick_read_excel() leaves no excel temp files behind", {
  before <- list.files(tempdir(), full.names = TRUE)
  quick_read_excel(xlsx_path)
  after  <- list.files(tempdir(), full.names = TRUE)
  new_files <- setdiff(after, before)
  expect_false(any(grepl("\\.(xls|xlsx)$", new_files)))
})
