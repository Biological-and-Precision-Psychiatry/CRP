# test_quick_read_excel.R

library(CRP)

if(requireNamespace("readxl", quietly = TRUE)) {
  # test quick_read_excel() - equivalence and differences to read_excel():
  read_excel_args <- formals(readxl::read_excel)
  quick_read_excel_args <- formals(CRP::quick_read_excel)
  stopifnot(
    all.equal(names(read_excel_args), names(quick_read_excel_args))
  )
}


