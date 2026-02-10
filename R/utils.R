# utils.R

################################################################################
## comma2numeric
################################################################################
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

################################################################################
## rbindall and cbindall
################################################################################
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


################################################################################
## rm.na
################################################################################
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

################################################################################
## first and last
################################################################################
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

################################################################################
## show_set
################################################################################
#' Detail union and intersection of two variables
#' 
#' Convenience function to compare two variables in terms of length, number of unique values, union, and intersection.
#'
#' @param A a vector
#' @param B a vector
#' @param unique compare only unique entries in `A` and `B`?
#'
#' @returns a `data.frame` with 1 row and columns `nA`, `nB`, `uniqueA`, `uniqueB`, `union` `intersect`, `AnotB`, `BnotA`
#' @author Rune Haubo B Christensen
#' @export
#'
#' @examples
#' 
#' head(iris)
#' with(iris, show_set(Sepal.Length, Petal.Length))
#' 
show_set <- function(A, B, unique = TRUE)  {
  stopifnot(length(unique) == 1L,
            is.logical(unique))
  nA <- length(A)
  nB <- length(B)
  if(unique) {
    A <- unique(A)
    B <- unique(B)
  }
  data.frame(nA = nA,
             nB = nB,
             uniqueA = length(A),
             uniqueB = length(B),
             union = length(union(A, B)),
             intersect = length(intersect(A, B)),
             AnotB = length(setdiff(A, B)),
             BnotA = length(setdiff(B, A)))
}