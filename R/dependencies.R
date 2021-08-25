#' 'shiny.react' JavaScript dependency
#'
#' @return An `htmlDependency` object which can be used attach the JavaScript code
#'   required by 'shiny.react'.
#'
#' @export
shinyReactDependency <- function() {
  htmltools::htmlDependency(
    name = "shiny.react",
    version = "0.1.0",
    package = "shiny.react",
    src = "www/shiny.react",
    script = "shiny-react.js"
  )
}

#' Enable 'React' debug mode
#'
#' Sets the `shiny.react_DEBUG` option to `TRUE`. In debug mode, 'shiny.react' will load a dev
#' version of 'React', which is useful for debugging. It will also set the logging level to DEBUG.
#'
#' @return Nothing. This function is called for its side effects.
#'
#' @export
enableReactDebugMode <- function() {
  options(`shiny.react_DEBUG` = TRUE)
  logger::log_threshold(logger::DEBUG, namespace = "shiny.react")
  invisible()
}

isDebugMode <- function() {
  getOption("shiny.react_DEBUG", default = FALSE)
}

#' 'React' library dependency
#'
#' @param useCdn If `TRUE`, 'React' will be loaded from a CDN instead of being served locally.
#' @return An `htmlDependency` object which can be used to attach the 'React' library.
#'
#' @export
reactDependency <- function(useCdn = FALSE) {
  fileVersionInfix <- if (isDebugMode()) "development" else "production.min" # nolint
  localPaths <- c(
    glue::glue("react.{fileVersionInfix}.js"),
    glue::glue("react-dom.{fileVersionInfix}.js")
  )
  cdnPaths <- c(
    glue::glue("react@17.0.1/umd/react.{fileVersionInfix}.js"),
    glue::glue("react-dom@17.0.1/umd/react-dom.{fileVersionInfix}.js")
  )

  depSources <- if (useCdn) {
    list(src = list(href = "//unpkg.com"), script = cdnPaths)
  } else {
    list(
      src = system.file("www/react", package = "shiny.react"),
      script = localPaths
    )
  }

  htmltools::htmlDependency(
    name = "react",
    version = reactVersion(),
    src = depSources$src,
    script = depSources$script
  )
}

#' @keywords internal
reactVersion <- function() {
  "17.0.1"
}

allShinyReactDependencies <- function() {
  list(
    reactDependency(),
    shinyReactDependency()
  )
}
