# rbind or cbind a list

A generalization of `rbind` and `cbind` to allow parsing a list of
objects as argument.

## Usage

``` r
rbindall(...)

cbindall(...)
```

## Arguments

- ...:

  objects to be `rbind`'ed or `cbind`'ed

## Value

the `rbind`'ed or `cbind`'ed result

## Details

The function definition is essentially
`rbindall <- function(...) do.call(rbind, ...)`

## Author

Rune Haubo B Christensen

## Examples

``` r
x <- lapply(1:3, function(i) runif(5))
rbindall(x)
#>            [,1]      [,2]      [,3]      [,4]       [,5]
#> [1,] 0.05144628 0.5302125 0.6958239 0.6885560 0.03123033
#> [2,] 0.22556253 0.3008308 0.6364656 0.4790245 0.43217126
#> [3,] 0.70643384 0.9485766 0.1803388 0.2168999 0.68016292
cbindall(x)
#>            [,1]      [,2]      [,3]
#> [1,] 0.05144628 0.2255625 0.7064338
#> [2,] 0.53021246 0.3008308 0.9485766
#> [3,] 0.69582388 0.6364656 0.1803388
#> [4,] 0.68855600 0.4790245 0.2168999
#> [5,] 0.03123033 0.4321713 0.6801629
```
