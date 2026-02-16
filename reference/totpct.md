# Add Column Total and Row Percentages to a `data.table` Tabulation

Add Column Total and Row Percentages to a `data.table` Tabulation

## Usage

``` r
totpct(tab, name_col = 1, n_col = 2, digits = 2)
```

## Arguments

- tab:

  a `data.table` tabulation; see Examples

- name_col:

  indicator of name column (character or numeric)

- n_col:

  indicator of the numeric column (character or numeric)

- digits:

  number of digits in percentages in result

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
