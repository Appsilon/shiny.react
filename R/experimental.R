testComponent <- function(name) {
  function(...) {
    reactElement(
      module = "@/shiny.react/test-components", name = name,
      props = asProps(...)
    )
  }
}

Box <- testComponent("Box") # nolint
Counter <- testComponent("Counter") # nolint
Pinger <- testComponent("Pinger") # nolint

#' React context
#'
#' Render children with React.
#'
#' @param ... Children to render.
#'
#' @examples
#' if (interactive()) shinyApp(
#'   ui = shiny.react:::ReactContext(
#'     "This text is rendered by React"
#'   ),
#'   server = function(input, output) {}
#' )
ReactContext <- testComponent("ReactContext") # nolint

ShinyBindingWrapper <- function(...) reactElement( # nolint
  module = "@/shiny.react", name = "ShinyBindingWrapper", props = asProps(...)
)
