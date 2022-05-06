#' Create a 'React' element
#'
#' Creates a `shiny.tag` which can be rendered just like other 'Shiny' tags as well as passed in
#' props to other 'React' elements. Typically returned from a wrapper ("component") function,
#' which parses its arguments with `asProps()` and fills in the other arguments.
#'
#' @param module JavaScript module to import the component from.
#' @param name Name of the component.
#' @param props Props to pass to the component.
#' @param deps HTML dependencies to attach.
#' @return A `shiny.tag` object representing the 'React' element.
#'
#' @seealso \code{\link{asProps}}
#'
#' @examples
#' Component <- function(...) reactElement(
#'   module = "@/module", name = "Component", props = asProps(...)
#' )
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
#' Converts arguments to a list which can be passed as the `props` argument to `reactElement()`.
#' Unnamed arguments become children and named arguments become attributes for the element.
#'
#' @param ... Arguments to prepare for passing as props to a 'React' component
#' @return A list of the arguments structured suitably for `reactElement()`.
#'
#' @seealso \code{\link{reactElement}}
#'
#' @export
asProps <- function(...) {
  args <- rlang::dots_list(..., .homonyms = "error")
  named <- nzchar(names(args))
  addChildrenToProps(props = args[named], children = unname(args[!named]))
}

#' 'React' output
#'
#' Creates a 'Shiny' output which can be used analogously to `shiny::uiOutput()` but preserves
#' 'React' state on re-renders.
#'
#' @param outputId Id that can be used to render React on the server
#' @return A `shiny.tag` object which can be placed in the UI.
#'
#' @seealso \code{\link{renderReact}}
#'
#' @examples
#' # This example uses some unexported test components. The components are not exported,
#' # as shiny.react is designed to only provide the machinery for building React-based packages.
#' # See shiny.fluent for a large number of examples.
#'
#' if (interactive()) {
#'   colors <- list("Gold", "Lavender", "Salmon")
#'
#'   shinyApp(
#'     ui = bootstrapPage(
#'       reactOutput("ui"),
#'       selectInput("color", label = "Background color", choices = colors)
#'     ),
#'     server = function(input, output) {
#'       output$ui <- renderReact(
#'         shiny.react:::Box(
#'           style = list(backgroundColor = input$color),
#'           shiny.react:::Pinger()
#'         )
#'       )
#'     }
#'   )
#' }
#'
#' @export
reactOutput <- function(outputId) reactContainer(id = outputId)

#' Render 'React'
#'
#' Renders HTML and/or 'React' in outputs created with `reactOutput()` (analogously to
#' `shiny::renderUI()`).
#'
#' @param expr Expression returning the HTML / 'React' to render.
#' @param env Environment in which to evaluate expr.
#' @param quoted Is `expr` a quoted expression?
#' @return A function which can be assigned to an output in a `Shiny` server function.
#'
#' @seealso \code{\link{reactOutput}}
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

#' Update 'React' input
#'
#' Updates inputs created with the help of `InputAdapter` function (part of the JavaScript
#' interface). Analogous to `shiny::updateX()` family of functions, but generic.
#'
#' If you're creating a wrapper package for a 'React' library, you'll probably want to provide
#' a dedicated update function for each input to imitate 'Shiny' interface.
#'
#' @param session Session object passed to function given to shinyServer.
#' @param inputId Id of the input object.
#' @param ... Props to modify.
#' @return Nothing. This function is called for its side effects.
#'
#' @export
updateReactInput <- function(session = shiny::getDefaultReactiveDomain(), inputId, ...) {
  session$sendCustomMessage("updateReactInput", list(
    inputId = session$ns(inputId), data = asReactData(asProps(...))
  ))
}

#' Mark character strings as literal JavaScript code
#'
#' Copied verbatim from the htmlwidgets package
#' to avoid adding a dependency just for this single function.
#'
#' @param ... Character vectors as the JavaScript source code
#'   (all arguments will be pasted into one character string).
#' @return The input character vector marked with a special class.
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
#' Creates a handler which can be used for `onClick` and similar props of 'React' components
#' to trigger an event in 'Shiny'.
#'
#' @param inputId 'Shiny' input ID to trigger the event on.
#' @return A `ReactData` object which can be passed as a prop to 'React' components.
#'
#' @export
triggerEvent <- function(inputId) ReactData(
  type = "input", id = inputId, argIdx = NULL
)

#' Set input
#'
#' Creates a handler which can be used for `onChange` and similar props of 'React' components
#' to set the value of a 'Shiny' input to one of the arguments passed to the handler.
#'
#' @param inputId 'Shiny' input ID to set the value on.
#' @param argIdx Index of the argument to use as value.
#' @param debounce The number of milliseconds to delay.
#' @param throttle The number of milliseconds to throttle invocations to.
#' @return A `ReactData` object which can be passed as a prop to 'React' components.
#'
#' @export
setInput <- function(inputId, argIdx = 1, debounce = NULL, throttle = NULL) ReactData(
  type = "input", id = inputId, argIdx = argIdx - 1, debounce = debounce, throttle = throttle
)
