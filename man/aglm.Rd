% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aglm.R
\name{aglm}
\alias{aglm}
\title{Fit an AGLM model with no cross-validation}
\usage{
aglm(
  x,
  y,
  qualitative_vars_UD_only = NULL,
  qualitative_vars_both = NULL,
  qualitative_vars_OD_only = NULL,
  quantitative_vars = NULL,
  use_LVar = FALSE,
  extrapolation = "default",
  add_linear_columns = TRUE,
  add_OD_columns_of_qualitatives = TRUE,
  add_interaction_columns = FALSE,
  OD_type_of_quantitatives = "C",
  nbin.max = NULL,
  bins_list = NULL,
  bins_names = NULL,
  family = c("gaussian", "binomial", "poisson"),
  ...
)
}
\arguments{
\item{x}{A design matrix.
Usually a \code{data.frame} object is expected, but a \code{matrix} object is fine if all columns are of a same class.
Each column may have one of the following classes, and \code{aglm} will automatically determine how to handle it:
\itemize{
\item \code{numeric}: interpreted as a quantitative variable. \code{aglm} performs discretization by binning, and creates dummy variables suitable for ordered values (named O-dummies/L-variables).
\item \code{factor} (unordered) or \code{logical} : interpreted as a qualitative variable without order. \code{aglm} creates dummy variables suitable for unordered values (named U-dummies).
\item \code{ordered}: interpreted as a qualitative variable with order. \code{aglm} creates both O-dummies and U-dummies.
}

These dummy variables are added to \code{x} and form a larger matrix, which is used internally as an actual design matrix.
See \href{https://www.institutdesactuaires.com/global/gene/link.php?doc_id=16273&fg=1}{our paper} for more details on O-dummies, U-dummies, and L-variables.

If you need to change the default behavior, use the following options: \code{qualitative_vars_UD_only}, \code{qualitative_vars_both}, \code{qualitative_vars_OD_only}, and \code{quantitative_vars}.}

\item{y}{A response variable.}

\item{qualitative_vars_UD_only}{Used to change the default behavior of \code{aglm} for given variables.
Variables specified by this parameter are considered as qualitative variables and only U-dummies are created as auxiliary columns.
This parameter may have one of the following classes:
\itemize{
\item \code{integer}: specifying variables by index.
\item \code{character}: specifying variables by name.
}}

\item{qualitative_vars_both}{Same as \code{qualitative_vars_UD_only}, except that both O-dummies and U-dummies are created for specified variables.}

\item{qualitative_vars_OD_only}{Same as \code{qualitative_vars_UD_only}, except that both only O-dummies are created for specified variables.}

\item{quantitative_vars}{Same as \code{qualitative_vars_UD_only}, except that specified variables are considered as quantitative variables.}

\item{use_LVar}{Set to use L-variables.
By default, \code{aglm} uses O-dummies as the representation of a quantitative variable.
If \code{use_LVar=TRUE}, L-variables are used instead.}

\item{extrapolation}{Used to control values of linear combination for quantitative variables, outside where the data exists.
By default, values of a linear combination outside the data is extended based on the slope of the edges of the region where the data exists.
You can set \code{extrapolation="flat"} to get constant values outside the data instead.}

\item{add_linear_columns}{By default, for quantitative variables, \code{aglm} expands them by adding dummies and the original columns, i.e. the linear effects, are remained in the resulting model.
You can set \code{add_linear_columns=FALSE} to drop linear effects.}

\item{add_OD_columns_of_qualitatives}{Set to \code{FALSE} if you do not want to use O-dummies for qualitative variables with order (usually, columns with \code{ordered} class).}

\item{add_interaction_columns}{If this parameter is set to \code{TRUE}, \code{aglm} creates an additional auxiliary variable \code{x_i * x_j} for each pair \verb{(x_i, x_j)} of variables.}

\item{OD_type_of_quantitatives}{Used to control the shape of linear combinations obtained by O-dummies for quantitative variables (deprecated).}

\item{nbin.max}{An integer representing the maximum number of bins when \code{aglm} perform binning for quantitative variables.}

\item{bins_list}{Used to set custom bins for variables with O-dummies.}

\item{bins_names}{Used to set custom bins for variables with O-dummies.}

\item{family}{A \code{family} object or a string representing the type of the error distribution.
Currently \code{aglm} supports \code{gaussian}, \code{binomial}, and \code{poisson}.}

\item{...}{Other arguments are passed directly when calling \code{glmnet()}.}
}
\value{
A model object fitted to the data.
Functions such as \code{predict} and \code{plot} can be applied to the returned object.
See \link{AccurateGLM-class} for more details.
}
\description{
A basic fitting function with given \eqn{\alpha} and \eqn{\lambda} (s).
See \link{aglm-package} for more details on \eqn{\alpha} and \eqn{\lambda}.
}
\examples{

#################### Gaussian case ####################

library(MASS) # For Boston
library(aglm)

## Read data
xy <- Boston # xy is a data.frame to be processed.
colnames(xy)[ncol(xy)] <- "y" # Let medv be the objective variable, y.

## Split data into train and test
n <- nrow(xy) # Sample size.
set.seed(2018) # For reproducibility.
test.id <- sample(n, round(n/4)) # ID numbders for test data.
test <- xy[test.id,] # test is the data.frame for testing.
train <- xy[-test.id,] # train is the data.frame for training.
x <- train[-ncol(xy)]
y <- train$y
newx <- test[-ncol(xy)]
y_true <- test$y

## Fit the model
model <- aglm(x, y)  # alpha=1 (the default value)

## Predict for various alpha and lambda
lambda <- 0.1
y_pred <- predict(model, newx=newx, s=lambda)
rmse <- sqrt(mean((y_true - y_pred)^2))
cat(sprintf("RMSE for lambda=\%.2f: \%.5f \n\n", lambda, rmse))

lambda <- 1.0
y_pred <- predict(model, newx=newx, s=lambda)
rmse <- sqrt(mean((y_true - y_pred)^2))
cat(sprintf("RMSE for lambda=\%.2f: \%.5f \n\n", lambda, rmse))

alpha <- 0
model <- aglm(x, y, alpha=alpha)

lambda <- 0.1
y_pred <- predict(model, newx=newx, s=lambda)
rmse <- sqrt(mean((y_true - y_pred)^2))
cat(sprintf("RMSE for alpha=\%.2f and lambda=\%.2f: \%.5f \n\n", alpha, lambda, rmse))

#################### Binomial case ####################

library(aglm)
library(faraway)

## Read data
xy <- nes96

## Split data into train and test
n <- nrow(xy) # Sample size.
set.seed(2018) # For reproducibility.
test.id <- sample(n, round(n/5)) # ID numbders for test data.
test <- xy[test.id,] # test is the data.frame for testing.
train <- xy[-test.id,] # train is the data.frame for training.
x <- train[, c("popul", "TVnews", "selfLR", "ClinLR", "DoleLR", "PID", "age", "educ", "income")]
y <- train$vote
newx <- test[, c("popul", "TVnews", "selfLR", "ClinLR", "DoleLR", "PID", "age", "educ", "income")]

## Fit the model
model <- aglm(x, y, family="binomial")

## Make the confusion matrix
lambda <- 0.1
y_true <- test$vote
y_pred <- levels(y_true)[as.integer(predict(model, newx, s=lambda, type="class"))]

print(table(y_true, y_pred))

#################### use_LVar and extrapolation ####################

library(MASS) # For Boston
library(aglm)

## Randomly created train and test data
set.seed(2021)
sd <- 0.2
x <- 2 * runif(1000) + 1
f <- function(x){x^3 - 6 * x^2 + 13 * x}
y <- f(x) + rnorm(1000, sd = sd)
xy <- data.frame(x=x, y=y)
x_test <- seq(0.75, 3.25, length.out=101)
y_test <- f(x_test) + rnorm(101, sd=sd)
xy_test <- data.frame(x=x_test, y=y_test)

## Plot
nbin.max <- 10
models <- c(cv.aglm(x, y, use_LVar=FALSE, extrapolation="default", nbin.max=nbin.max),
            cv.aglm(x, y, use_LVar=FALSE, extrapolation="flat", nbin.max=nbin.max),
            cv.aglm(x, y, use_LVar=TRUE, extrapolation="default", nbin.max=nbin.max),
            cv.aglm(x, y, use_LVar=TRUE, extrapolation="flat", nbin.max=nbin.max))

titles <- c("O-Dummies with extrapolation=\"default\"",
            "O-Dummies with extrapolation=\"flat\"",
            "L-Variables with extrapolation=\"default\"",
            "L-Variables with extrapolation=\"flat\"")

par.old <- par(mfrow=c(2, 2))
for (i in 1:4) {
  model <- models[[i]]
  title <- titles[[i]]

  pred <- predict(model, newx=x_test, s=model@lambda.min, type="response")

  plot(x_test, y_test, pch=20, col="grey", main=title)
  lines(x_test, f(x_test), lty="dashed", lwd=2)  # the theoretical line
  lines(x_test, pred, col="blue", lwd=3)  # the smoothed line by the model
}
par(par.old)
}
\references{
Suguru Fujita, Toyoto Tanaka, Kenji Kondo and Hirokazu Iwasawa. (2020)
\emph{AGLM: A Hybrid Modeling Method of GLM and Data Science Techniques}, \cr
\url{https://www.institutdesactuaires.com/global/gene/link.php?doc_id=16273&fg=1} \cr
\emph{Actuarial Colloquium Paris 2020}
}
\author{
\itemize{
\item Kenji Kondo,
\item Kazuhisa Takahashi and Hikari Banno (worked on L-Variable related features)
}
}
