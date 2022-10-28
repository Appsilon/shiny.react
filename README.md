<img src="man/figures/shiny-react.png" align="right" alt="" width="130" />

# shiny.react

<!-- badges: start -->
[![CI](https://github.com/Appsilon/shiny.react/actions/workflows/ci.yaml/badge.svg)](https://github.com/Appsilon/shiny.react/actions/workflows/ci.yaml)
<!-- badges: end -->

This R package enables using React in Shiny apps and is used e.g. by the shiny.fluent package.
It contains R and JS code which is independent from the React library (e.g. Fluent UI) that is being wrapped.

To install the package, run `remotes::install_github("Appsilon/shiny.react")`.

### Development

To build and install the package, run:
```sh
(cd js && yarn && yarn webpack)
Rscript -e 'devtools::document(); devtools::install()'
```

### Testing

* `cd js && yarn lint` lints the JS code
* `cd js && yarn test` runs the unit tests for the JS code
* `Rscript -e "lintr::lint_package()"` runs linter for the R code
* `Rscript -e "devtools::test()"` runs unit tests for the R code
