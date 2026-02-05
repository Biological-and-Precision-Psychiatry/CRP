#' Bias correction factor
#'
#' @param k Degrees of freedom
#' @return Numeric
#'
#' @examples
#' k2f(10)
#'
#' @keywords internal
k2f <- function(k) {
  sqrt(k / 2) * gamma((k - 1) / 2) / gamma(k / 2)
}
