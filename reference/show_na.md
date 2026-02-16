# Summarize `NA` values in a `data.table`

Summarize `NA` values in a `data.table`

## Usage

``` r
show_na(d)
```

## Arguments

- d:

  a `data.table` or `data.frame`

## Value

A `matrix` summarizing the number of `NA`s and zero-length characters

## Author

Rune Haubo B Christensen

## Examples

``` r
show_na(airquality)
#>         NAs n0chars NAor0
#> Ozone   37  NA      37   
#> Solar.R 7   NA      7    
#> Wind    0   NA      0    
#> Temp    0   NA      0    
#> Month   0   NA      0    
#> Day     0   NA      0    
show_na(iris)
#>              NAs n0chars NAor0
#> Sepal.Length 0   NA      0    
#> Sepal.Width  0   NA      0    
#> Petal.Length 0   NA      0    
#> Petal.Width  0   NA      0    
#> Species      0   NA      0    
```
