# Detail union and intersection of two variables

Convenience function to compare two variables in terms of length, number
of unique values, union, and intersection.

## Usage

``` r
show_set(A, B, unique = TRUE)
```

## Arguments

- A:

  a vector

- B:

  a vector

- unique:

  compare only unique entries in `A` and `B`?

## Value

a `data.frame` with 1 row and columns `nA`, `nB`, `uniqueA`, `uniqueB`,
`union` `intersect`, `AnotB`, `BnotA`

## Author

Rune Haubo B Christensen

## Examples

``` r
head(iris)
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
#> 5          5.0         3.6          1.4         0.2  setosa
#> 6          5.4         3.9          1.7         0.4  setosa
with(iris, show_set(Sepal.Length, Petal.Length))
#>    nA  nB uniqueA uniqueB union intersect AnotB BnotA
#> 1 150 150      35      43    54        24    11    19
```
