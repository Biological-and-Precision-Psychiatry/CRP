# data.table_utils.R


################################################################################
## totpct
################################################################################
#' Add Column Total and Row Percentages to a `data.table` Tabulation
#'
#' @param tab a `data.table` tabulation; see Examples
#' @param name_col indicator of name column (character or numeric)
#' @param n_col indicator of the numeric column (character or numeric)
#' @param digits number of digits in percentages in result
#'
#' @returns `tab` with appended total-row and percent-column
#' @author Rune Haubo B Christensen
#' @export
#' @importFrom varhandle check.numeric
#' @importFrom data.table ':=' copy
#'
#' @examples
#' 
#' Iris <- as.data.table(iris)
#'
#' tab <- Iris[, .N, Species]
#' totpct(tab)
#'
#' tab <- Iris[, .(Mean = mean(Sepal.Length), .N), Species]
#' totpct(tab, n_col = 3, digits=1)
#' 
totpct <- function(tab, name_col=1, n_col=2, digits=2) {
  Pct <- NULL # To make R CMD check happy
  stopifnot(ncol(tab) >= 2,
            name_col != n_col)
  tab1 <- copy(tab)
  nm <- names(tab1)
  
  ## Coerce n-variable to numeric:
  if(is.numeric(n_col)) {
    stopifnot(n_col > 0 & n_col <= ncol(tab))
    n_col <- nm[n_col]
  }
  if(!n_col %in% nm) stop("Cannot find variable '", n_col, "' in 'tab'")  
  if(!all(varhandle::check.numeric(tab1[, get(n_col)]))) 
    stop("Cannot coerce variable '", n_col, "' to numeric")
  tab1[, (n_col) := suppressWarnings(as.numeric(get(n_col)))]
  
  ## Handle name-variable:
  if(is.numeric(name_col)) {
    stopifnot(name_col > 0 & name_col <= ncol(tab))
    name_col <- nm[name_col]
  }
  tab1[, (name_col) := as.character(get(name_col))]
  
  ## Calculate 'Total':
  tab_tot <- tab1[1]
  for(x in nm) tab_tot[, (x) := NA]
  tab_tot[, (name_col) := "Total"]
  Sum <- tab1[, sum(get(n_col), na.rm = TRUE)]
  tab_tot[, (n_col) := Sum]
  
  ## Calculate 'Pct':
  tab2 <- rbind(tab1, tab_tot)
  tab2[, Pct := do_format(get(n_col) / Sum * 100, digits)]
  tab2[]
}


################################################################################
## show_na
################################################################################
#' Summarize `NA` values in a `data.table`
#'
#' @param d a `data.table` or `data.frame` 
#'
#' @returns A `matrix` summarizing the number of `NA`s and zero-length characters
#' @author Rune Haubo B Christensen
#' @importFrom data.table copy setDT
#' @export
#'
#' @examples
#' 
#' show_na(airquality)
#' show_na(iris)
#' 
show_na <- function(d) {
  if(!inherits(d, "data.table")) d <- copy(d)
  setDT(d)
  nms <- names(d)
  nas <- sapply(d, function(x) sum(is.na(x)))
  ischar <- sapply(d, is.character)
  n0chars <- rep(NA_real_, length(nms))
  n0chars[ischar] <- sapply(d[, ischar, with=FALSE], function(x) 
    sum(nchar(rm.na(x)) == 0))
  cbind(NAs = nas, n0chars, 
        NAor0 = ifelse(is.na(n0chars), nas, nas + n0chars))
}