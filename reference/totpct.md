# Add column total and row percentages to a `data.table` tabulation

Add column total and row percentages to a `data.table` tabulation

## Usage

``` r
totpct(tab, name_col = 1, n_col = 2, digits = 2)
```

## Arguments

- tab:

  a `data.table` tabulation; see Examples

- name_col:

  name or index of the label column (character or integer)

- n_col:

  name or index of the count/numeric column (character or integer)

- digits:

  number of decimal places in the percentage column

## Value

`tab` with appended total-row and percent-column

## Author

Rune Haubo B Christensen

## Examples

``` r
Iris <- as.data.table(iris)

tab <- Iris[, .N, Species]
totpct(tab)
#>       Species     N    Pct
#>        <char> <num> <char>
#> 1:     setosa    50  33.33
#> 2: versicolor    50  33.33
#> 3:  virginica    50  33.33
#> 4:      Total   150 100.00

tab <- Iris[, .(Mean = mean(Sepal.Length), .N), Species]
totpct(tab, n_col = 3, digits=1)
#>       Species  Mean     N    Pct
#>        <char> <num> <num> <char>
#> 1:     setosa 5.006    50   33.3
#> 2: versicolor 5.936    50   33.3
#> 3:  virginica 6.588    50   33.3
#> 4:      Total    NA   150  100.0
```
