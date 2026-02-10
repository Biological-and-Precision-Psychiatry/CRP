
################################################################################
## do_format
################################################################################
#' Format numbers as text with fixed number of decimals
#' 
#' Improves the formatting of numbers to text over direct applications of 
#' `round` and `format` as illustrated in examples.
#'
#' @param x numeric vector of values to format as text
#' @param digits number of digits in the formatted number
#'
#' @returns the input `x` formatted to text (character vector)
#' @export
#'
#' @examples
#' # Simple example:
#' do_format(1.23456)
#' do_format(c(1, 2), 3)
#' 
#' # Note that round() looses the last digit:
#' do_format(1.20)
#' round(1.20, digits=2)
#' 
#' # Note that here format() doesn't round correctly:
#' do_format(1.206)
#' format(1.206, digits=2)
do_format <- function(x, digits = 2) {
  stopifnot(is.numeric(x),
            length(x) > 0,
            is.numeric(digits),
            length(digits) == 1L)
  trimws(format(round(x, digits[1L]), nsmall = digits[1L], scientific = FALSE))
}

################################################################################
## format_estci
################################################################################
#' Format estimate with confidence interval 
#' 
#' Format as "estimate (lower - upper)" 
#'
#' @param est parameter estimate (numeric scalar)
#' @param lwr lower limit (numeric scalar)
#' @param upr upper limit (numeric scalar)
#' @param digits number of digits (numeric scalar)
#' @param ci_sep CI separator
#' @param use_exp exp-transform `est`, `lwr`, and `upr` 
#' @param upr_lim upper limit for printing of `upr` applied when `use_exp` is `TRUE` to avoid very large numbers.
#'
#' @returns The text "estimate (lower - upper)" (character vector)
#' @export
#' @seealso [do_format()] used for the formatting of estimate, lower and upper
#'
#' @examples
#' 
#' # Basic usage:
#' format_estci(1.2, 0.8, 1.6)
#' 
#' # Change CI-separator:
#' format_estci(1.2, 0.8, 1.6, ci_sep="; ")
#' 
#' # Multiple point and interval estimates:
#' format_estci(1:2, 0:1, 2:3)
#' 
#' # Illustrate use of use_exp argument:
#' format_estci(1:2, 0:1, 2:3, use_exp = TRUE)
#' 
#' # When use_exp = TRUE the upper limit is capped at upr_lim = 100: 
#' format_estci(1:2, 0:1, 4:5, use_exp = TRUE)
#' 
format_estci <- function(est, lwr, upr, digits = 2, ci_sep = " - ", 
                         use_exp = FALSE, upr_lim = 100) {
  sapply(c(est, lwr, upr), function(arg) 
    stopifnot(is.numeric(arg), 
              length(arg) > 0))
  sapply(c(digits, ci_sep, use_exp, upr_lim), function(arg)
    stopifnot(length(arg) == 1L))
  stopifnot(length(est) == length(lwr),
            length(est) == length(upr),
            is.numeric(digits),
            is.character(ci_sep),
            is.logical(use_exp),
            is.numeric(upr_lim))
  
  if(use_exp) {
    est <- exp(est)
    lwr <- exp(lwr)
    upr <- exp(upr)
  }
  paste0(
    do_format(est, digits),
    " (",
    do_format(lwr, digits),
    ci_sep,
    ifelse(use_exp & upr > upr_lim, 
           paste0(">", upr_lim), do_format(upr, digits)),
    ")")
}


################################################################################
## format_pval2
################################################################################
#' Format p-values consistently 
#'
#' Easy to use modification of `format.pval`.
#'
#' @param p Numeric p-values
#' @param digits Number of digits
#' 
#' @return Character vector
#' 
#' @seealso [format.pval()] which is called internally
#'
#' @examples
#' format_pval2(0.03456)
#' format_pval2(1e-6)
#'
#' @export
format_pval2 <- function(p, digits = 3) {
  stopifnot(is.numeric(p),
            length(p) > 0,
            is.numeric(digits),
            length(digits) == 1L)
  format.pval(round(p, digits),
              digits = digits,
              eps = 10^(-digits),
              scientific = FALSE,
              nsmall = digits)
}
