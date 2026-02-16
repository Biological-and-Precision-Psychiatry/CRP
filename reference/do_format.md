# Format numbers as text with fixed number of decimals

Improves the formatting of numbers to text over direct applications of
`round` and `format` as illustrated in examples.

## Usage

``` r
do_format(x, digits = 2)
```

## Arguments

- x:

  numeric vector of values to format as text

- digits:

  number of digits in the formatted number

## Value

the input `x` formatted to text (character vector)

## Author

Rune Haubo B Christensen

## Examples

``` r
# Simple example:
do_format(1.23456)
#> [1] "1.23"
do_format(c(1, 2), 3)
#> [1] "1.000" "2.000"

# Note that round() looses the last digit:
do_format(1.20)
#> [1] "1.20"
round(1.20, digits=2)
#> [1] 1.2

# Note that here format() doesn't round correctly:
do_format(1.206)
#> [1] "1.21"
format(1.206, digits=2)
#> [1] "1.2"
```
