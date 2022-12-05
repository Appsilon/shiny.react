# shiny.react <a href="https://appsilon.github.io/shiny.react/"><img src="man/figures/shiny-react.png" align="right" alt="shiny.react logo" style="height: 140px;"></a>

> _Use React in Shiny applications._

<!-- badges: start -->
[![CRAN
status](https://www.r-pkg.org/badges/version/shiny.react)](https://cran.r-project.org/package=shiny.react)
[![cranlogs](https://cranlogs.r-pkg.org/badges/shiny.react)](https://CRAN.R-project.org/package=shiny.react)
[![total](https://cranlogs.r-pkg.org/badges/grand-total/shiny.react)](https://CRAN.R-project.org/package=shiny.react)
[![CI](https://github.com/Appsilon/shiny.react/actions/workflows/ci.yaml/badge.svg)](https://github.com/Appsilon/shiny.react/actions/workflows/ci.yaml)
<!-- badges: end -->

This R package enables using React in Shiny apps and is used e.g. by the [`shiny.fluent`](https://appsilon.github.io/shiny.fluent/) package.
It contains R and JS code which is independent from the React library (e.g. Fluent UI) that is being wrapped.

## Installation

Stable version:

```r
install.packages("shiny.react")
```

Development version:

```r
remotes::install_github("Appsilon/shiny.react")
```

## Development

To build and install the package, run:
```sh
(cd js && yarn && yarn webpack)
Rscript -e 'devtools::document(); devtools::install()'
```

## Testing

* `cd js && yarn lint` lints the JS code
* `cd js && yarn test` runs the unit tests for the JS code
* `Rscript -e "lintr::lint_package()"` runs linter for the R code
* `Rscript -e "devtools::test()"` runs unit tests for the R code

## How to contribute?

If you want to contribute to this project please submit a regular PR, once you're done with a new feature or bug fix.

Reporting a bug is also helpful - please use [GitHub issues](https://github.com/Appsilon/shiny.react/issues) and describe your problem as detailed as possible.

## Appsilon

<img src="https://avatars0.githubusercontent.com/u/6096772" align="right" alt="" width="6%" />

Appsilon is a **Posit (formerly RStudio) Full Service Certified Partner**.<br/>
Learn more
at [appsilon.com](https://appsilon.com).

Get in touch [opensource@appsilon.com](opensource@appsilon.com)

Check our [Open Source tools](https://shiny.tools).

<a href = "https://appsilon.com/careers/" target="_blank"><img src="http://d2v95fjda94ghc.cloudfront.net/hiring.png" alt="We are hiring!"/></a>
