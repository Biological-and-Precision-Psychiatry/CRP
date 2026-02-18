do_format <- function(x, dig=2) 
  trimws(format(round(x, dig), nsmall=dig, scientific = FALSE))

format_estci <- function(est, lwr, upr, digits=2) {
  paste0(do_format(est), " (", do_format(lwr), " - ", do_format(upr), ")")
}
