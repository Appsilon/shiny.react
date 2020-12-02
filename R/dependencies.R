html_dependency_shiny_react <- function() {
  htmltools::htmlDependency(
    name = "shiny.react",
    src = "www/shiny.react",
    version = "0.1.0",
    script = c("shiny-react.js"),
    package = "shiny.react"
  )
}

html_dependency_react <- function(use_cdn = FALSE, dev = FALSE) {
  file_version_infix <- if (dev) "development" else "production.min" # nolint
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
