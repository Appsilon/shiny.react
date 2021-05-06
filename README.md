# shiny.react R package

<!-- badges: start -->
[![R build status](https://github.com/Appsilon/shiny.react/workflows/R-CMD-check/badge.svg)](https://github.com/Appsilon/shiny.react/actions)
<!-- badges: end -->

This R package enables using React in Shiny apps and is used e.g. by the shiny.fluent package.
It contains R and JS code which is independent from the React library (e.g. Fluent UI) that is being wrapped.

To install the package, run `devtools::install_git("ssh://git@github.com/Appsilon/shiny.react.git")`
For this to work, you will need SSH access to the private shiny.react repository.
If you run into problems, try installing SSH dependencies and re-installing git2r:
```
sudo apt-get install libssh2-1 libssh2-1-dev
Rscript -e 'devtools::install_cran("git2r", force = TRUE)'
```

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
