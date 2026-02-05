# journal.R

library(devtools)
# has_devel()
r2path <- "~/GitHub/CRP/CRP"
# document(pkg=r2path, roclets = c("namespace", "rd"))
document(pkg=r2path)
load_all(r2path)


#####################################################################
## 2026-02-05

format_estci(1.2, 0.8, 1.6)
format_estci(1.2, 0.8, 1.6, ci_sep="; ")
format_estci(1:2, 0:1, 2:3)
format_pval2(runif(1)*1e-1)

#####################################################################
