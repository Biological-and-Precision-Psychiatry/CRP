# Comma to numeric

Convert a character vector containing numbers with comma as decimal
separator to a numeric vector. This is achieved by substituting `,` with
`.` using `gsub` and coercing the result using `as.numeric`.

## Usage

``` r
comma2numeric(x)
```

## Arguments

- x:

  a character vector of numbers with comma as decimal separator

## Value

a numeric vector

## Author

Rune Haubo B Christensen

## Examples

``` r
x <- c("0,0903", "0,7374", "0,6462", "0,6463", "0,5534", "0,622")
comma2numeric(x)
#> [1] 0.0903 0.7374 0.6462 0.6463 0.5534 0.6220
```
