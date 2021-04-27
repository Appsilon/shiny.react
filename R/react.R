#' Create a React element
#'
#' @param module JavaScript module to import the component from.
#' @param name Name of the component.
#' @param props Props to pass to the component.
#' @param deps HTML dependencies to attach.
#'
#' @export
reactElement <- function(module, name, props, deps = NULL) {
  props <- asReactData(props)
  reactContainer(data = ReactData(
    type = "element",
    module = module,
    name = name,
    props = dropDeps(props),
    deps = list(getDeps(props), deps)
  ))
}

#' Parse arguments as props
#'
#' @param ... Arguments to prepare for passing as props to a React component
#'
#' @export
asProps <- function(...) {
  args <- rlang::dots_list(..., .homonyms = "error")
  named <- nzchar(names(args))
  addChildren(props = args[named], children = unname(args[!named]))
}

#' React output
#'
#' @param outputId Id that can be used to render React on the server
#'
#' @export
reactOutput <- function(outputId) reactContainer(id = outputId)

#' Render React
#'
#' @param expr Expression returning the HTML / React to render.
#' @param env Environment in which to evaluate expr.
#' @param quoted Is expr a quoted expression?
#'
#' @export
renderReact <- function(expr, env = parent.frame(), quoted = FALSE) {
  func <- shiny::exprToFunction(expr, env, quoted)
  function() {
    data <- asReactData(func())
    deps <- lapply(
      htmltools::resolveDependencies(getDeps(data)),
      function(x) toJson(shiny::createWebDependency(x), force = TRUE)
    )
    toJson(list(data = data, deps = deps))
  }
}

#' Update React input
#'
#' @param session Session object passed to function given to shinyServer.
#' @param inputId Id of the input object.
#' @param ... Props to modify.
#'
#' @export
updateReactInput <- function(session = shiny::getDefaultReactiveDomain(), inputId, ...) {
  session$sendCustomMessage("updateReactInput", list(
    inputId = inputId, data = asReactData(asProps(...))
  ))
}

#' Mark character strings as literal JavaScript code
#'
#' Copied verbatim from the htmlwidgets package
#' to avoid adding a dependency just for this single function.
#'
#' @param ... Character vectors as the JavaScript source code
#'
#' @export
JS <- function(...) { # nolint
  x <- c(...)
  if (is.null(x)) return()
  if (!is.character(x)) stop("The arguments for JS() must be a character vector")
  x <- paste(x, collapse = "\n")
  structure(x, class = unique(c("JS_EVAL", oldClass(x))))
}

#' Trigger event
#'
#' @param inputId Shiny input ID to trigger the event on.
#'
#' @export
triggerEvent <- function(inputId) ReactData(
  type = "input", id = inputId, argIdx = NULL
)

#' Set input
#'
#' @param inputId Shiny input ID to set the value on.
#' @param argIdx Index of the argument to use as value.
#'
#' @export
setInput <- function(inputId, argIdx = 1) ReactData(
  type = "input", id = inputId, argIdx = argIdx - 1
)
