# utils.R

#' Comma to numeric
#' 
#' Convert a character vector containing numbers with comma as decimal separator
#' to a numeric vector. This is achieved by substituting `,` with `.` using `gsub`
#' and coercing the result using `as.numeric`.
#'
#' @param x a character vector of numbers with comma as decimal separator
#'
#' @returns a numeric vector
#' @export
#' @author Rune Haubo B Christensen
#'
#' @examples
#' 
#' x <- c("0,0903", "0,7374", "0,6462", "0,6463", "0,5534", "0,622")
#' comma2numeric(x)
#' 
comma2numeric <- function(x) {
  as.numeric(gsub(",", ".", x))
}

#' rbind or cbind a list
#'
#' A generalization of `rbind` and `cbind` to allow parsing a list of objects
#' as argument. 
#' 
#' The function definition is essentially 
#' `rbindall <- function(...) do.call(rbind, ...)`
#'
#' @param ... objects to be `rbind`'ed or `cbind`'ed
#'
#' @returns the `rbind`'ed or `cbind`'ed result
#' @export 
#' @author Rune Haubo B Christensen
#'
#' @examples
#' 
#' x <- lapply(1:3, function(i) runif(5))
#' rbindall(x)
#' cbindall(x)
#' 
rbindall <- function(...) {
  do.call(rbind, ...)
}

#' @rdname rbindall
#' @export
cbindall <- function(...) {
  do.call(cbind, ...)
}


#' Remove NA from Vector
#'
#' @param x vector possibly with `NA` values
#'
#' @returns input vector `x` cleaned of `NA` values
#' @author Rune Haubo B Christensen
#' @export
#'
#' @examples
#' 
#' x <- c(-1.09, NA, 1.21, -0.23, NA, 0.31, -0.28)
#' rm.na(x)
#' 
rm.na <- function(x) {
  x[!is.na(x)]
} 

#' Get First or Last Element
#'
#' @param x a vector 
#'
#' @returns the first or last element
#' @author Rune Haubo B Christensen
#' @export
#'
#' @examples
#' 
#' x <- rnorm(5)
#' x
#' first(x)
#' last(x)
#' 
first <- function(x) {
  x[1]
}

#' @rdname first
#' @export
last <- function(x) {
  x[length(x)]
}