# shiny.react R package

<!-- badges: start -->
[![R build status](https://github.com/Appsilon/shiny.react/workflows/R-CMD-check/badge.svg)](https://github.com/Appsilon/shiny.react/actions)
<!-- badges: end -->

This R package is used by the generated wrapper packages.

It contains R and JS code which is independent from the React library being wrapped.

To build and install it, run:
```sh
yarn && yarn webpack
Rscript -e 'devtools::document(); devtools::install()'
```

### Testing
* `yarn lint` lints the JS code
* `yarn test` runs the unit tests for the JS code
* `Rscript -e "lintr::lint_package()"` runs linter for the R code
* `Rscript -e "devtools::test()"` runs unit tests for the R code
