# Extract coefficient table with CI and p-value from a model fit

Extract coefficient table with CI and p-value from a model fit

## Usage

``` r
get_coeftab(
  model,
  coef_name,
  transform = function(x) x,
  ci_method = confint.default,
  digits = 3,
  digits.p = 3,
  ci_sep = " - ",
  return = c("est_ci_pval", "all")
)
```

## Arguments

- model:

  a model fit such as that produced by `lm` or `glm`

- coef_name:

  name of coefficient for which to get coefficient table

- transform:

  optional function (e.g., `exp`) for a log-linear model

- ci_method:

  `method` to obtain confidence intervals

- digits:

  number of digits

- digits.p:

  number of digits in p-value

- ci_sep:

  CI separator

- return:

  return est, CI and p-value (`"est_ci_pval"`) or all values (`"all"`)

## Value

a `data.table` with return values

## Author

Rune Haubo B Christensen

## Examples

``` r
fm <- lm(speed ~ dist, data=cars)
summary(fm)
#> 
#> Call:
#> lm(formula = speed ~ dist, data = cars)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -7.5293 -2.1550  0.3615  2.4377  6.4179 
#> 
#> Coefficients:
#>             Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)  8.28391    0.87438   9.474 1.44e-12 ***
#> dist         0.16557    0.01749   9.464 1.49e-12 ***
#> ---
#> Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#> 
#> Residual standard error: 3.156 on 48 degrees of freedom
#> Multiple R-squared:  0.6511, Adjusted R-squared:  0.6438 
#> F-statistic: 89.57 on 1 and 48 DF,  p-value: 1.49e-12
#> 
get_coeftab(fm, "dist")
#>                   est_ci pvalue
#>                   <char> <char>
#> 1: 0.166 (0.130 - 0.201) <0.001

fm <- lm(Ozone ~ Solar.R + Wind + Temp, data=airquality)
summary(fm)
#> 
#> Call:
#> lm(formula = Ozone ~ Solar.R + Wind + Temp, data = airquality)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -40.485 -14.219  -3.551  10.097  95.619 
#> 
#> Coefficients:
#>              Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) -64.34208   23.05472  -2.791  0.00623 ** 
#> Solar.R       0.05982    0.02319   2.580  0.01124 *  
#> Wind         -3.33359    0.65441  -5.094 1.52e-06 ***
#> Temp          1.65209    0.25353   6.516 2.42e-09 ***
#> ---
#> Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#> 
#> Residual standard error: 21.18 on 107 degrees of freedom
#>   (42 observations deleted due to missingness)
#> Multiple R-squared:  0.6059, Adjusted R-squared:  0.5948 
#> F-statistic: 54.83 on 3 and 107 DF,  p-value: < 2.2e-16
#> 
get_coeftab(fm, c("Solar.R", "Wind", "Temp"), ci_sep = "; ")
#>                     est_ci pvalue
#>                     <char> <char>
#> 1:    0.060 (0.014; 0.106)  0.011
#> 2: -3.334 (-4.631; -2.036) <0.001
#> 3:    1.652 (1.149; 2.155) <0.001
```
