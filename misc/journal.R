# journal.R

library(devtools)
# has_devel()
r2path <- "~/GitHub/CRP/CRP"
# document(pkg=r2path, roclets = c("namespace", "rd"))
document(pkg=r2path)
load_all(r2path)


#####################################################################
## 2026-02-05

?quick_read_excel
readxl::readxl_example()

path <- system.file("extdata", "clippy.xls", package = "readxl", mustWork = TRUE)
quick_read_excel(path)
ls()


path_to_file <- system.file("extdata", "clippy.xlsx", package = "readxl", 
                            mustWork = TRUE)
quick_read_excel(path_to_file)

tools::file_ext(path)
file_ex

# [x] Make example of using quick_read_excel - see ?read_excel for inspiration
# [o] 
# [o] 

#####################################################################
## 2026-02-05

format_estci(1.2, 0.8, 1.6)
format_estci(1.2, 0.8, 1.6, ci_sep="; ")
format_estci(1:2, 0:1, 2:3)
format_estci(1:2, 0:1, 2:3, use_exp = TRUE)
format_estci(1:2, 0:1, 4:5, use_exp = TRUE)

log(100)

format_pval2(runif(1)*1e-1)

#####################################################################
