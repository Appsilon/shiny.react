#' Shiny React JS dependency.
#'
#' @export
html_dependency_shiny_react <- function() {
  htmltools::htmlDependency(
    name = "shiny.react",
    src = "www/shiny.react",
    version = "0.1.0",
    script = c("shiny-react.js"),
    package = "shiny.react"
  )
}

#' Sets shiny.react into DEBUG mode.
#'
#' Sets the `shiny.react_DEBUG` option to `value`. In DEBUG mode, shiny.react will load a dev version of JS code including React,
#' which is useful for debugging. It will also set a DEBUG logging level and pretty print tags representation sent to client.
#'
#' @export
enable_react_debug_mode <- function(){
  options(`shiny.react_DEBUG` = TRUE)
  logger::log_threshold(logger::DEBUG, namespace="shiny.react")
}

is_debug_mode <- function(){
  getOption("shiny.react_DEBUG", default = FALSE)
}

#' Shiny React dependency adding React libs.
#'
#' @param use_cdn If true, will load React from CDN instead of serving locally.
#' @export
html_dependency_react <- function(use_cdn = FALSE) {
  file_version_infix <- if (is_debug_mode()) "development" else "production.min" # nolint
  local_paths <- c(
    glue::glue("react.{file_version_infix}.js"),
    glue::glue("react-dom.{file_version_infix}.js")
  )
  cdn_paths <- c(
    glue::glue("react@16/umd/react.{file_version_infix}.js"),
    glue::glue("react-dom@16/umd/react-dom.{file_version_infix}.js")
  )

  dep_sources <- if (use_cdn) {
    list(src = list(href = "//unpkg.com"), script = cdn_paths)
  } else {
    list(
      src = system.file("www/react", package = "shiny.react"),
      script = local_paths
    )
  }

  htmltools::htmlDependency(
    name = "react",
    version = react_version(),
    src = dep_sources$src,
    script = dep_sources$script
  )
}

#' @keywords internal
react_version <- function() {
  "16.13.1"
}

all_shiny_react_dependencies <- function() {
  list(
    html_dependency_react(),
    html_dependency_shiny_react()
  )
}
