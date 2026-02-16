# Remove NA from Vector

Remove NA from Vector

## Usage

``` r
rm.na(x)
```

## Arguments

- x:

  vector possibly with `NA` values

## Value

input vector `x` cleaned of `NA` values

## Author

Rune Haubo B Christensen

## Examples

``` r
x <- c(-1.09, NA, 1.21, -0.23, NA, 0.31, -0.28)
rm.na(x)
#> [1] -1.09  1.21 -0.23  0.31 -0.28
```
