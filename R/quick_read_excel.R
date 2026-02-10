
#' Quickly read excel files from network drives
#' 
#' `readxl::read_excel` is very slow when reading excel files from network 
#' drives. This function fixes that by copying the file to a temporary file that
#' exists on a local drive which is then quickly read using `readxl::read_excel`. 
#' 
#' The temporary file is made using `base::tempfile` and deleted using 
#' `base::unlink` and `base::on.exit` when exiting from `quick_read_excel`.
#' 
#' All arguments are taken verbatim from `readxl::read_excel`.
#' 
#' @inheritParams readxl::read_excel
#'
#' @returns A tibble
#' @seealso [readxl::read_excel()] for further details on the behavior of the 
#' function
#' @author Rune Haubo B Christensen
#' @export
#' @importFrom readxl read_excel readxl_progress
#' @importFrom tools file_ext
#'
#' @examples
#' 
#' # Reading an xls-file:
#' path_to_file <- system.file("extdata", "clippy.xls", package = "readxl", 
#'                             mustWork = TRUE)
#' quick_read_excel(path_to_file)
#' 
#' # Reading an xlsx-file:
#' path_to_file <- system.file("extdata", "clippy.xlsx", package = "readxl", 
#'                             mustWork = TRUE)
#' quick_read_excel(path_to_file)
#' 
#' # Use readxl::readxl_example() for more excel file examples.
#' 
#' # See readxl::read_excel for more examples
#' 
quick_read_excel <- function(path, sheet = NULL, range = NULL, col_names = TRUE, 
                             col_types = NULL, na = "", trim_ws = TRUE, skip = 0, 
                             n_max = Inf, guess_max = min(1000, n_max), 
                             progress = readxl_progress(), 
                             .name_repair = "unique") {
  stopifnot(file.exists(path))
  file.ext <- tools::file_ext(path)
  TMP_FILE <- tempfile(fileext = paste0(".", file.ext))
  on.exit(unlink(TMP_FILE))
  file_copy_success <- file.copy(path, TMP_FILE)
  if(!file_copy_success) stop("Failed to copy 'path' to a temporary file.")
  read_excel(TMP_FILE, sheet = sheet, range = range, col_names = col_names, 
             col_types = col_types, na = na, trim_ws = trim_ws, skip = skip, 
             n_max = n_max, guess_max = guess_max, progress = progress, 
             .name_repair = .name_repair)
}