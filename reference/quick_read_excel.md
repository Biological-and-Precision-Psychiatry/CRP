# Quickly read excel files from network drives

[`readxl::read_excel`](https://readxl.tidyverse.org/reference/read_excel.html)
is very slow when reading excel files from network drives. This function
fixes that by copying the file to a temporary file that exists on a
local drive which is then quickly read using
[`readxl::read_excel`](https://readxl.tidyverse.org/reference/read_excel.html).

## Usage

``` r
quick_read_excel(
  path,
  sheet = NULL,
  range = NULL,
  col_names = TRUE,
  col_types = NULL,
  na = "",
  trim_ws = TRUE,
  skip = 0,
  n_max = Inf,
  guess_max = min(1000, n_max),
  progress = readxl_progress(),
  .name_repair = "unique"
)
```

## Arguments

- path:

  Path to the xls/xlsx file.

- sheet:

  Sheet to read. Either a string (the name of a sheet), or an integer
  (the position of the sheet). Ignored if the sheet is specified via
  `range`. If neither argument specifies the sheet, defaults to the
  first sheet.

- range:

  A cell range to read from, as described in
  [cell-specification](https://readxl.tidyverse.org/reference/cell-specification.html).
  Includes typical Excel ranges like "B3:D87", possibly including the
  sheet name like "Budget!B2:G14", and more. Interpreted strictly, even
  if the range forces the inclusion of leading or trailing empty rows or
  columns. Takes precedence over `skip`, `n_max` and `sheet`.

- col_names:

  `TRUE` to use the first row as column names, `FALSE` to get default
  names, or a character vector giving a name for each column. If user
  provides `col_types` as a vector, `col_names` can have one entry per
  column, i.e. have the same length as `col_types`, or one entry per
  unskipped column.

- col_types:

  Either `NULL` to guess all from the spreadsheet or a character vector
  containing one entry per column from these options: "skip", "guess",
  "logical", "numeric", "date", "text" or "list". If exactly one
  `col_type` is specified, it will be recycled. The content of a cell in
  a skipped column is never read and that column will not appear in the
  data frame output. A list cell loads a column as a list of length 1
  vectors, which are typed using the type guessing logic from
  `col_types = NULL`, but on a cell-by-cell basis.

- na:

  Character vector of strings to interpret as missing values. By
  default, readxl treats blank cells as missing data.

- trim_ws:

  Should leading and trailing whitespace be trimmed?

- skip:

  Minimum number of rows to skip before reading anything, be it column
  names or data. Leading empty rows are automatically skipped, so this
  is a lower bound. Ignored if `range` is given.

- n_max:

  Maximum number of data rows to read. Trailing empty rows are
  automatically skipped, so this is an upper bound on the number of rows
  in the returned tibble. Ignored if `range` is given.

- guess_max:

  Maximum number of data rows to use for guessing column types.

- progress:

  Display a progress spinner? By default, the spinner appears only in an
  interactive session, outside the context of knitting a document, and
  when the call is likely to run for several seconds or more. See
  [`readxl_progress()`](https://readxl.tidyverse.org/reference/readxl_progress.html)
  for more details.

- .name_repair:

  Handling of column names. Passed along to
  [`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html).
  readxl's default is \`.name_repair = "unique", which ensures column
  names are not empty and are unique.

## Value

A tibble

## Details

The temporary file is made using
[`base::tempfile`](https://rdrr.io/r/base/tempfile.html) and deleted
using [`base::unlink`](https://rdrr.io/r/base/unlink.html) and
[`base::on.exit`](https://rdrr.io/r/base/on.exit.html) when exiting from
`quick_read_excel`.

All arguments are taken verbatim from
[`readxl::read_excel`](https://readxl.tidyverse.org/reference/read_excel.html).

## See also

[`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html)
for further details on the behavior of the function

## Author

Rune Haubo B Christensen

## Examples

``` r
# Reading an xls-file:
path_to_file <- system.file("extdata", "clippy.xls", package = "readxl", 
                            mustWork = TRUE)
quick_read_excel(path_to_file)
#> # A tibble: 4 × 2
#>   name                 value              
#>   <chr>                <chr>              
#> 1 Name                 Clippy             
#> 2 Species              paperclip          
#> 3 Approx date of death 39083              
#> 4 Weight in grams      0.90000000000000002

# Reading an xlsx-file:
path_to_file <- system.file("extdata", "clippy.xlsx", package = "readxl", 
                            mustWork = TRUE)
quick_read_excel(path_to_file)
#> # A tibble: 4 × 2
#>   name                 value    
#>   <chr>                <chr>    
#> 1 Name                 Clippy   
#> 2 Species              paperclip
#> 3 Approx date of death 39083    
#> 4 Weight in grams      0.9      

# Use readxl::readxl_example() for more excel file examples.

# See readxl::read_excel for more examples
```
