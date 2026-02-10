# journal.R

library(devtools)
# has_devel()
r2path <- "~/GitHub/CRP/CRP"
# document(pkg=r2path, roclets = c("namespace", "rd"))
document(pkg=r2path)
load_all(r2path)


#####################################################################
## 2026-02-05

x <- round(rnorm(7), 2)
x[c(2, 5)] <- NA

x <- c(-1.09, NA, 1.21, -0.23, NA, 0.31, -0.28)
rm.na(x)


x
first(x)
last(x)

?rbindall

x <- as.character(round(runif(6), 4))
x <- gsub(".", ",", x, fixed = TRUE)
dput(x)
x <- c("0,0903", "0,7374", "0,6462", "0,6463", "0,5534", "0,622")
comma2numeric(x)
comma2numeric(x)

x <- lapply(1:3, function(i) runif(5))
rbindall(x)
cbindall(x)

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
