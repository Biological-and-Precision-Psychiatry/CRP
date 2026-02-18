rm.na <- function(x) x[!is.na(x)]
first <- function(x) x[1]
last <- function(x) x[length(x)]

totpct <- function(tab, name_col=1, n_col=2, digits=2) {
  stopifnot(requireNamespace("varhandle", quietly = TRUE))
  # Add total-row and Percent-column to a 1-D table (data.table type)
  stopifnot(require(data.table))
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
# totpct(tab)

show_set <- function(A, B, unique = TRUE)  {
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

show_na <- function(d) { # d <- copy(pop)
  nms <- names(d)
  nas <- sapply(d, function(x) sum(is.na(x)))
  ischar <- sapply(d, is.character)
  n0chars <- rep(NA_real_, length(nms))
  n0chars[ischar] <- sapply(d[, ischar, with=FALSE], function(x) 
    sum(nchar(rm.na(x)) == 0))
  cbind(NAs = nas, n0chars, 
        NAor0 = ifelse(is.na(n0chars), nas, nas + n0chars))
}

quick_read_excel <- function(path, sheet = NULL, range = NULL, col_names = TRUE, 
                             col_types = NULL, na = "", trim_ws = TRUE, skip = 0, 
                             n_max = Inf, guess_max = min(1000, n_max), progress = readxl_progress(), 
                             .name_repair = "unique") {
  stopifnot(file.exists(path))
  TMP_FILE <- tempfile(fileext = ".xlsx")
  file_copy_success <- file.copy(path, TMP_FILE)
  d <- read_excel(TMP_FILE, sheet = sheet, range = range, col_names = col_names, 
                  col_types = col_types, na = na, trim_ws = trim_ws, skip = skip, 
                  n_max = n_max, guess_max = guess_max, progress = progress, 
                  .name_repair = .name_repair)
  unlink(TMP_FILE)
  d  
}

