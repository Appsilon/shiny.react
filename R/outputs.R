#' Make Shiny output
#'
#' A helper which can be used to define a function behaving
#' just as Shiny output functions do.
#'
#' @param html_dependencies htmltools dependencies to attach (if NULL dependencies will not be attached).
#' @param package_name Package identifier, components should be in \code{window[package_name]} on the client.
#' @param component_name Component name on the client: should be in \code{window[package_name][component_name]}.
#' @param ... Arguments and children to be passed to the React component.
#'
#' @export
make_output <- function(html_dependencies, package_name, component_name, ...) {
  component_args <- rlang::dots_list(...)
  function(...) {
    contents <- c(component_args, rlang::dots_list(...))
    component <- htmltools::tag(paste0(component_name), contents, .noWS = NULL)
    if (!is.null(html_dependencies)) {
      component <- htmltools::attachDependencies(component, html_dependencies)
    }
    mark_as_react_tag(package_name, component)
  }
}

#' Shiny Component Wrapper
#'
#' Use if your component isn't visible on the start, disappears and appears
#' to make sure inputs and outputs are bound.
#'
#' @param ... Component to be wrapped.
#'
#' @export
ShinyComponentWrapper <- shiny.react:::make_output( # nolint
  NULL,
  "ShinyReact",
  "ShinyComponentWrapper"
)
