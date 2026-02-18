## Functions:

# source("./misc_functions.R")

###################################################################
## Formatting:

do_format <- function(x, dig=2)
  trimws(format(round(x, dig), nsmall=dig, scientific = FALSE))

format.pval2 <- function(p, digits=3) {
  d <- digits
  format.pval(round(p, d), digits=d, eps=10^(-d),
              scientific=FALSE, nsmall=d)
}
effect_ci <- function(estimate, lwr, upr, dig=3, ci_sep = " - ") {
  paste0(do_format(estimate, dig=dig), " (", 
         do_format(lwr, dig=dig), ci_sep, 
         do_format(upr, dig=dig), ")")
}

effect_ci2 <- function(estimate, lwr, upr, dig=3, ci_sep = " - ", upr_tol=100, exp=FALSE) {
  if(exp) {
    estimate <- exp(estimate)
    lwr <- exp(lwr)
    upr <- exp(upr)
  }
  paste0(do_format(estimate, dig=dig), " (", 
         do_format(lwr, dig=dig), ci_sep, 
         ifelse(upr > upr_tol, paste0(">", upr_tol), do_format(upr, dig=dig)), ")")
}


###################################################################
## Misc functions
comma2numeric <- function(x) as.numeric(gsub(",", ".", x))

rbindall <- function(...) do.call(rbind, ...)
cbindall <- function(...) do.call(cbind, ...)

###################################################################
## Extract effect functions:

get_effect <- function(model, coef_name, transform = function(x) x, ci_method=confint.default,
                       digits=3, digits.p=3, ci_sep = " - ", return=c("est_ci_pval", "all")) {
  stopifnot(require(data.table))
  return <- match.arg(return)
  
  b <- coef(summary(model))
  ci <- if(inherits(model, "lm") & !inherits(model, "glm")) confint(model) else ci_method(model)
  stopifnot(coef_name %in% rownames(b))
  res <- as.data.table(cbind(b[coef_name, , drop=FALSE], ci[coef_name, , drop=FALSE]))[, -3]
  colnms <- colnames(res)
  pval_nm <- colnms[grep("Pr\\(>", colnms)]
  nms <- c(colnames(b)[1], colnames(ci))
  res[, (nms) := transform(.SD), .SDcols=nms]
  res[, pvalue := format.pval2(get(pval_nm), digits = digits.p)]
  res[, est_ci := effect_ci(Estimate, `2.5 %`, `97.5 %`, dig = digits, ci_sep = ci_sep)]
  if(return == "all") res[] else res[, .(est_ci, pvalue)]
}


###################################################################
## Derive SD from groups:

get_sd_pooled <- function(n, sd) sqrt(sum((n-1) * sd^2) / (sum(n) - length(n)))
totvar <- function(means, vars, probs) {
  ## Calculate V[X] given E[X|y_i] and V[X|y_i] where Y has outcomes i=1, ... n 
  ## each with probability p_i. 
  ## means = E[X|y_i], vars = V[X|y_i] and probs = p_i
  stopifnot(length(means) == length(vars),
            length(means) == length(probs))
  probs <- probs / sum(probs)
  mu <- sum(probs * means)
  sum(probs * vars) + (sum(probs * means^2) - mu^2)
}

totvarCH <- function(means, vars, ns) {
  ## Cochrane Handbook formula for combining groups applied consecutively 
  ## on two groups.
  stopifnot(length(means) == length(vars),
            length(means) == length(ns))
  if(length(vars) == 1L) return(vars)
  fun <- function(m, v, n) {
    q <- (n[1] - 1)*v[1] + (n[2] - 1)*v[2] + 
      (prod(n)/sum(n))*(m[1]^2 + m[2]^2 - 2*m[1]*m[2])
    q / (sum(n) - 1)
  }
  mat <- cbind(means, vars, ns)
  cmean <- weighted.mean(means[1:2], ns[1:2])
  cvar <- fun(means[1:2], vars[1:2], ns[1:2])
  if(length(means) == 2) return(cvar)
  for(i in 3:length(means)) {
    cvar <- fun(c(cmean, means[i]), c(cvar, vars[i]), c(sum(ns[1:(i-1)]), ns[i]))
    cmean <- weighted.mean(means[1:i], ns[1:i])
  }
  cvar
}


collapse_groups <- function(ns, means, vars) {
  # Compute n, mean and sd from a set of groups
  ns <- ns[!is.na(ns)]
  means <- means[!is.na(means)]
  vars <- vars[!is.na(vars)]
  c("n"=sum(ns), 
    "mu"=weighted.mean(means, ns),
    "sd"=sqrt(totvarCH(means, vars, ns))) # CH-variance
}
# collapse_groups(c(10, 23), c(31.8, 30.33), c(6.34, 6.23)^2)

###################################################################
## Standardized mean and its SD

k2f <- function(k) {
  sqrt(k / 2) * 
    gamma((k - 1) / 2 ) / 
    gamma(k / 2)
}

std_mean <- function(n, mean, sd) {
  k <- n - 1 # degrees of freedom
  mean / sd / k2f(n-1) # bias corrected mean
}

std_mean_se <- function(n, mean, sd) {
  lambda <- sqrt(n) * mean / sd
  k <- n - 1
  num <- k * (1 + lambda^2)
  den <- k2f(k) * (k - 2)
  g <- num / den - lambda^2
  var <- g / n
  sqrt(var)
}


###################################################################
## Derive SD from p or t-values:

t2sediff <- function(means, t) {
  stopifnot(length(t) == 1,
            length(means) == 2)
  SE <- abs(diff(means) / t)
  SE
}

p2t <- function(pvalue, ns) {
  stopifnot(length(pvalue) == 1, pvalue > 0, pvalue < 1,
            length(ns) == 2, all(ns > 0))
  tvalue <- abs(qt(pvalue/2, df=sum(ns) - 2, lower.tail = FALSE))
  tvalue
}

sediff2sd <- function(ns, sediff) {
  stopifnot(length(sediff) == 1, sediff > 0,
            length(ns) == 2, all(ns > 0))
  nn <- sqrt(sum(1/ns))
  SD <- sediff / nn
  SD
}

ci2se <- function(ci, n, level=0.95)  {
  stopifnot(length(ci) == 2, ci[1] < ci[2],
            length(n) == 1, n > 0, 
            length(level) == 1, level > 0, level < 1)
  alpha <- 1 - level
  lwr <- ci[1]
  upr <- ci[2]
  muhat <- (upr + lwr)/2
  f <- upr - muhat
  se <- f / qt(1-alpha/2, n-1)
  se
}

geom2ci <- function(gmean, gsd, n, level=0.95) {
  stopifnot(length(gmean) == 1, gmean > 0,
            length(gsd) == 1, gsd > 0,
            length(n) == 1, n > 0, 
            length(level) == 1, level > 0, level < 1)
  alpha <- 1 - level
  log_upr <- log(gmean) + qt(1 - alpha/2, df=n-1) * log(gsd) / sqrt(n)
  log_lwr <- log(gmean) - qt(1 - alpha/2, df=n-1) * log(gsd) / sqrt(n)
  c(lwr=exp(log_lwr), upr=exp(log_upr))
}

ci2sediff <- function(ci, ns, level=0.95) {
  stopifnot(length(ci) == 2, ci[1] < ci[2],
            length(ns) == 2, all(ns > 0),
            length(level) == 1, level > 0, level < 1)
  alpha <- 1 - level
  SEdiff <- abs(ci[2] - ci[1]) / (2 * qt(1 - alpha/2, df=sum(ns) - 2))
  SEdiff
} 

sd2se <- function(n, sd) {
  stopifnot(length(sd) == 1, sd > 0,
            length(n) == 1, n > 0)
  SE <- sd / sqrt(n)
  SE
}

se2sd <- function(n, se) {
  stopifnot(length(se) == 1, se > 0,
            length(n) == 1, n > 0)
  SD <- se * sqrt(n)
  SD
}

t2smd <- function(ns, means, t) {
  se_diff <- t2sediff(means, t)
  SD <- sediff2sd(ns, se_diff)
  diff(means) / SD
}
# tvalue <- 10.124
# t2smd(ns, means, tvalue)

# ns <- c(54, 56)
# means <- c(56.05, 54.92)
# pval <- 0.445
# 
# (tval <- p2t(pval, ns))^2
# (sediff <- t2sediff(means, tval))
# (sd_avg <- sediff2sd(ns, sediff))
# (sems <- sd_avg / sqrt(ns))
# 
# 
# simple.2sample.t.test(ns, means, vars=rep(sd_avg^2, 2))
# simple.2sample.t.test(ns, means, sems = sems)
# simple.2sample.t.test(ns, means, vars=(sems*sqrt(ns))^2)

###################################################################

simple.2sample.t.test <- function(ns, means, vars, sems) {
  stopifnot(require(data.table),
            all(c(ns) > 0),
            length(ns) == 2,
            length(means) == 2)
  if(!missing(vars)) stopifnot(length(vars) == 2)
  if(!missing(sems)) stopifnot(length(sems) == 2)
  #           (!missing(vars) & length(vars) == 2) | (!missing(sems) & length(sems) == 2))
  if(missing(vars)) {
    vars <- (sems * sqrt(ns))^2
  }
  
  Diff <- means[2] - means[1] 
  df <- sum(ns - 1)
  var_pooled <- sum((ns - 1) * vars) / df
  n_effective <-  2/(sum(1/ns))
  var_diff <- var_pooled / (n_effective / 2)
  se_diff <- sqrt(var_diff)
  T_stat1 <- Diff / se_diff
  pval_num <- 2 * pt(abs(T_stat1), df = df, lower.tail = FALSE)
  lwr <- Diff - qt(0.975, df=df) * se_diff 
  upr <- Diff + qt(0.975, df=df) * se_diff 
  
  d1 <- data.table(type = "var equal", Diff, SE=se_diff, "2.5%" = lwr, "97.5%" = upr, var_pooled, 
                   n_effective, df, T_stat=T_stat1, p_value = format.pval2(pval_num))
  
  
  ## Welch / Satterthwaites test:
  var_diff <- sum(vars / ns)
  se_diff <- sqrt(var_diff)
  df_est_num <- var_diff^2 
  df_est_den <- sum( (vars / ns)^2 / (ns - 1) )
  df_est <- df_est_num / df_est_den
  
  T_stat2 <- Diff / se_diff
  pval_num <- 2 * pt(abs(T_stat2), df = df_est, lower.tail = FALSE)
  lwr <- Diff - qt(0.975, df=df_est) * se_diff 
  upr <- Diff + qt(0.975, df=df_est) * se_diff 
  
  d2 <- data.table(type = "Welch", Diff, SE=se_diff, "2.5%" = lwr, "97.5%" = upr, var_pooled, 
             n_effective, df=df_est, T_stat=T_stat2, p_value = format.pval2(pval_num))
  rbind(d1, d2)
}

# x <- 1:10
# y <- 7:20
# d <- list(x=x, y=y)
# ns <- sapply(d, length)
# means <- sapply(d, mean)
# vars <- sapply(d, var)
# sqrt(vars)
# sems <- sqrt(vars / ns) 
# t.test(x, y, var.equal = TRUE)
# t.test(x, y, var.equal = FALSE)
# 
# simple.2sample.t.test(ns, means, vars)
# simple.2sample.t.test(ns, means, sems=sems)
# simple.2sample.t.test(c(167, 180), c(24.6, 27.7), c(2.65, 2.94)^2)
# 
# # BMI (p=0.553):
# simple.2sample.t.test(ns=c(167, 180), means=c(24.6, 24.7), sems=c(2.65, 2.94))
# simple.2sample.t.test(ns=c(167, 180), means=c(24.6, 24.7), sems=c(2.65, 2.94)/2)
# simple.2sample.t.test(ns=c(167, 180), means=c(24.6, 24.7), vars=c(2.65, 2.94)^2)
# simple.2sample.t.test(ns=c(167, 180), means=c(24.6, 24.7), vars=c(2.65, 2.94))
# 
# simple.2sample.t.test(ns=c(131, 180), means=c(24.6, 24.7), sems=c(2.65, 2.94))
# simple.2sample.t.test(ns=c(131, 180), means=c(24.6, 24.7), sems=c(2.65, 2.94)/2)
# simple.2sample.t.test(ns=c(131, 180), means=c(24.6, 24.7), vars=c(2.65, 2.94)^2)
# simple.2sample.t.test(ns=c(131, 180), means=c(24.6, 24.7), vars=c(2.65, 2.94))
# 
# # Leukocyte:
# simple.2sample.t.test(ns=c(167, 180), means=c(6.1, 6.0), sems=c(1.46, 1.51))
# 
# 
# # Neutrophil (p = 0.272):
# simple.2sample.t.test(ns=c(167, 180), means=c(3.6, 3.4), sems=c(1.1, 1.11))
# simple.2sample.t.test(ns=c(167, 180), means=c(3.6, 3.4), sems=c(1.1, 1.11)/2)
# simple.2sample.t.test(ns=c(167, 180), means=c(3.6, 3.4), vars=c(1.1, 1.11)^2)
# simple.2sample.t.test(ns=c(167, 180), means=c(3.6, 3.4), vars=c(1.1, 1.11))
# 
# simple.2sample.t.test(ns=c(131, 180), means=c(3.6, 3.4), sems=c(1.1, 1.11))
# simple.2sample.t.test(ns=c(131, 180), means=c(3.6, 3.4), sems=c(1.1, 1.11)*2)
# simple.2sample.t.test(ns=c(131, 180), means=c(3.6, 3.4), vars=c(1.1, 1.11)^2)
# simple.2sample.t.test(ns=c(131, 180), means=c(3.6, 3.4), vars=c(1.1, 1.11))
# 
# 
# # NLR (p = 0.025): 
# simple.2sample.t.test(ns=c(167, 180), means=c(1.9, 1.7), sems=c(0.73, 0.62))
# simple.2sample.t.test(ns=c(167, 180), means=c(1.9, 1.7), sems=c(0.73, 0.62)/2)
# simple.2sample.t.test(ns=c(167, 180), means=c(1.9, 1.7), vars=c(0.73, 0.62))
# simple.2sample.t.test(ns=c(167, 180), means=c(1.9, 1.7), vars=c(0.73, 0.62)^2)
# 
# simple.2sample.t.test(ns=c(131, 180), means=c(1.9, 1.7), sems=c(0.73, 0.62))
# simple.2sample.t.test(ns=c(131, 180), means=c(1.9, 1.7), sems=c(0.73, 0.62)*2)
# simple.2sample.t.test(ns=c(131, 180), means=c(1.9, 1.7), vars=c(0.73, 0.62))
# simple.2sample.t.test(ns=c(131, 180), means=c(1.9, 1.7), vars=c(0.73, 0.62)^2)
# 
# 
# # RDW (p < 0.001): 
# simple.2sample.t.test(ns=c(167, 180), means=c(13.4, 12.9), sems=c(0.87, 0.58))
# simple.2sample.t.test(ns=c(167, 180), means=c(13.4, 12.9), sems=c(0.87, 0.58)/2)
# simple.2sample.t.test(ns=c(167, 180), means=c(13.4, 12.9), vars=c(0.87, 0.58))
# simple.2sample.t.test(ns=c(167, 180), means=c(13.4, 12.9), vars=c(0.87, 0.58)^2)
# 
# simple.2sample.t.test(ns=c(131, 180), means=c(13.4, 12.9), sems=c(0.87, 0.58))
# simple.2sample.t.test(ns=c(131, 180), means=c(13.4, 12.9), sems=c(0.87, 0.58)/2)
# simple.2sample.t.test(ns=c(131, 180), means=c(13.4, 12.9), vars=c(0.87, 0.58))
# simple.2sample.t.test(ns=c(131, 180), means=c(13.4, 12.9), vars=c(0.87, 0.58)^2)
# 
# # dev.new()
# hist(x <- rnorm(167, mean=13.4, sd=0.87))
# hist(y <- rnorm(180, mean=12.9, sd=0.58))
# t.test(x, y)
# 
# (sd <- sqrt(167) * 0.87)
# hist(rnorm(167, mean=13.4, sd=sd))
# 
# 
# # Hemoglobin (p < 0.001):
# simple.2sample.t.test(ns=c(167, 180), means=c(137.3, 145.1), sems=c(14.69, 15.21))
# simple.2sample.t.test(ns=c(167, 180), means=c(137.3, 145.1), sems=c(14.69, 15.21)/2)
# simple.2sample.t.test(ns=c(167, 180), means=c(137.3, 145.1), vars=c(14.69, 15.21)^2) # sd
# simple.2sample.t.test(ns=c(167, 180), means=c(137.3, 145.1), vars=c(14.69, 15.21))

