# Format numbers as text with fixed number of decimals

Improves the formatting of numbers to text over direct applications of
`round` and `format` by always rounding correctly and also returning the
expected number of decimals.

## Usage

``` r
do_format(x, digits = 2)
```

## Arguments

- x:

  numeric vector of values to format as text

- digits:

  number of decimal places in the formatted output

## Value

the input `x` formatted to text (character vector)

## Author

Rune Haubo B Christensen

## Examples

``` r
# Simple example:
do_format(1.23456)
#> [1] "1.23"
do_format(c(1, 2), digits = 3)
#> [1] "1.000" "2.000"

# Note that round() may loose the last decimal:
round(1.20, digits = 2)
#> [1] 1.2
# But do_format preserves the requested 2 decimals:
do_format(1.20, digits = 2)
#> [1] "1.20"

# Using format() can be tricky:
format(1.206, nsmall = 2)
#> [1] "1.206"
format(1.206, digits = 2)
#> [1] "1.2"
# But do_format gives a useful result:
do_format(1.206, digits = 2)
#> [1] "1.21"
```
