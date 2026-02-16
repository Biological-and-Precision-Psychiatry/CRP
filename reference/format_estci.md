# Format estimate with confidence interval

Format as "estimate (lower - upper)"

## Usage

``` r
format_estci(
  est,
  lwr,
  upr,
  digits = 2,
  ci_sep = " - ",
  use_exp = FALSE,
  upr_lim = 100
)
```

## Arguments

- est:

  parameter estimate (numeric scalar)

- lwr:

  lower limit (numeric scalar)

- upr:

  upper limit (numeric scalar)

- digits:

  number of digits (numeric scalar)

- ci_sep:

  CI separator

- use_exp:

  exp-transform `est`, `lwr`, and `upr`

- upr_lim:

  upper limit for printing of `upr` applied when `use_exp` is `TRUE` to
  avoid very large numbers.

## Value

The text "estimate (lower - upper)" (character vector)

## See also

[`do_format()`](https://biological-and-precision-psychiatry.github.io/CRP/reference/do_format.md)
used for the formatting of estimate, lower and upper

## Author

Rune Haubo B Christensen

## Examples

``` r
# Basic usage:
format_estci(1.2, 0.8, 1.6)
#> [1] "1.20 (0.80 - 1.60)"

# Change CI-separator:
format_estci(1.2, 0.8, 1.6, ci_sep="; ")
#> [1] "1.20 (0.80; 1.60)"

# Multiple point and interval estimates:
format_estci(1:2, 0:1, 2:3)
#> [1] "1.00 (0.00 - 2.00)" "2.00 (1.00 - 3.00)"

# Illustrate use of use_exp argument:
format_estci(1:2, 0:1, 2:3, use_exp = TRUE)
#> [1] "2.72 (1.00 - 7.39)"  "7.39 (2.72 - 20.09)"

# When use_exp = TRUE the upper limit is capped at upr_lim = 100: 
format_estci(1:2, 0:1, 4:5, use_exp = TRUE)
#> [1] "2.72 (1.00 - 54.60)" "7.39 (2.72 - >100)" 
```
