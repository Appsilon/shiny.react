#' Creates a Shiny React widget that can be then rendered on the client with React
#'
#' @param ... tags to be rendered
#'
#' @import htmlwidgets
#'
#' @export
reactWidget <- function(...) { # nolint
  serialized <- prepare_for_rendering(htmltools::tagList(...))

  htmlwidgets::createWidget(
    name = "shinyreact",
    list(tag = serialized$tags_json),
    width = NULL,
    height = NULL,
    package = "shiny.react",
    elementId = NULL,
    dependencies = serialized$dependencies,
    sizingPolicy = htmlwidgets::sizingPolicy(
      browser.fill = TRUE
    )
  )
}

#' Shiny binding for shiny.react HTML widget
#'
#' @param outputId output variable to read from
#' @param width,height Dimensions for the widget
#'
#' @export
reactOutput <- function(outputId, width = "100%", height = "400px") { # nolint
  htmlwidgets::shinyWidgetOutput(outputId, "shinyreact", width, height, package = "shiny.react")
}

#' Shiny binding for shiny.react HTML widget
#'
#' @param expr Expression to be rendered
#' @param env Environment to be used
#' @param quoted Is expression quoted?
#'
#' @export
renderReact <- function(expr, env = parent.frame(), quoted = FALSE) { # nolint
  if (!quoted) {
    expr <- substitute(expr)
  }
  htmlwidgets::shinyRenderWidget(expr, reactOutput, env, quoted = TRUE)
}
