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
triggerEvent <- function(inputId) {
  ReactData(
    type = "event", id = inputId
  )
}

#' Set input
#'
#' Creates a handler which can be used for `onChange` and similar
#' props of 'React' components to set the value of a 'Shiny' input to one of
#' the arguments passed to the handler.
#'
#' The argument `jsAccessor` can be empty (assumes `jsAccessor = 0`) or
#' take one of the following types:
#'
#' - A valid javscript accessor string to be applied to the object
#' (example: `jsAccessor = "[0].target.checked"`)
#' - A valid javascript 0-based index (that unlike R it starts at 0)
#'
#' As an example, calling `setInput("some_index", 1)` is equivalent to
#' `setInput("some_index", "[1]")`
#'
#' @param inputId 'Shiny' input ID to set the value on.
#' @param jsAccessor Index (numeric 0-based index) or accessor (javascript string) of the argument
#' to use as value.
#' @return A `ReactData` object which can be passed as a prop to 'React'
#' components.
#'
#' @export
methods::setGeneric(
  "setInput",
  function(inputId, jsAccessor) {
    stop("Arguments not supported, see the documentation.")
  }
)

#' @describeIn setInput Uses as index `jsAccessor = 0`
#' @export
#' @examples
#' # Same as `setInput("some_id", 0)`.
#' setInput("some_id")
methods::setMethod(
  "setInput",
  signature(inputId = "character", jsAccessor = "missing"),
  function(inputId) {
    setInput(inputId, 0)
  }
)

#' @describeIn setInput Gets the value from index in jsAccessor
#' @export
#' @examples
#'
#' # Equivalent to `(...args) => Shiny.setInputValue('some_id', args[1])` in JS.
#' setInput("some_id", 1)
methods::setMethod(
  "setInput",
  signature(inputId = "character", jsAccessor = "numeric"),
  function(inputId, jsAccessor) {
    if (jsAccessor < 0 || jsAccessor - floor(jsAccessor) != 0) {
      stop(glue::glue("Arguments not supported :: index '{jsAccessor}' is invalid"))
    }
    ReactData(
      type = "input",
      id = inputId,
      jsAccessor = as.character(glue::glue("[{jsAccessor}]"))
    )
  }
)

#' @describeIn setInput Gets value via accessor, for instance,
#' the equivalent for a checkbox with `jsAccessor = 0` is
#' `jsAccessor = "[0].target.checked"`
#' @export
#' @examples
#'
#' # Same as `setInput("some_id", 1)`.
#' setInput("some_id", "[1]")
#'
#' # Equivalent to `(...args) => Shiny.setInputValue('some_id', args[0].target.value)` in JS.
#' setInput("some_id", "[0].target.value")
methods::setMethod(
  "setInput",
  signature(inputId = "character", jsAccessor = "character"),
  function(inputId, jsAccessor) {
    ReactData(
      type = "input", id = inputId, jsAccessor = jsAccessor
    )
  }
)
