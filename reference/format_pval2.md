# Format p-values consistently

Easy to use modification of `format.pval`.

## Usage

``` r
format_pval2(p, digits = 3)
```

## Arguments

- p:

  Numeric p-values

- digits:

  Number of digits

## Value

Character vector

## See also

[`format.pval()`](https://rdrr.io/r/base/format.pval.html) which is
called internally

## Author

Rune Haubo B Christensen

## Examples

``` r
format_pval2(0.03456)
#> [1] "0.035"
format_pval2(1e-6)
#> [1] "<0.001"
```
