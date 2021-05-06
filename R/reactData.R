ReactData <- function(..., deps = NULL) { # nolint
  structure(list(...),
    class = c("ReactData", "list"),
    html_dependencies = flattenDeps(deps)
  )
}

asReactData <- function(x) UseMethod("asReactData")

#' @export
asReactData.ReactData <- function(x) x

#' @export
asReactData.default <- function(x) ReactData(
  type = "raw",
  value = dropDeps(x),
  deps = getDeps(x)
)

#' @export
asReactData.html_dependency <- function(x) ReactData(
  type = "raw",
  value = NULL,
  deps = x
)

#' @export
asReactData.JS_EVAL <- function(x) ReactData(
  type = "expr",
  value = dropDeps(unclass(x)),
  deps = getDeps(x)
)

checkNames <- function(x) {
  # `toJson()` converts named lists to JSON objects, and unnamed lists to JSON arrays. A list `x`
  # is considered to be named when `!is.null(names(x))`, even if all names are empty strings.
  # Elements with empty names get automatic numeric labels, which is unlikely to be desirable.
  unnamed <- !nzchar(names(x))
  if (all(unnamed)) {
    x <- unname(x)
  } else if (any(unnamed)) {
    stop("When passing a list to React, either all or no elements must be named")
  }
  x
}

#' @export
asReactData.list <- function(x) {
  data <- lapply(checkNames(x), asReactData) # Process elements recursively.
  deps <- list(lapply(data, getDeps), getDeps(x))
  value <- lapply(data, dropDeps)
  if (all(lapply(value, `[[`, "type") == "raw")) {
    # If all elements are raw values, we can unpack them and mark the whole list as raw.
    # This way we decrease the JSON size and skip some recursive processing on the client.
    value <- lapply(value, `[[`, "value")
    type <- "raw"
  } else {
    type <- if (is.null(names(value))) "array" else "object"
  }
  ReactData(type = type, value = value, deps = deps)
}

#' @export
asReactData.shiny.tag <- function(x) { # nolint
  # A `shiny.tag` created with `reactContainer()` will have a `reactData` attribute attached
  # with a ReactData representation of whatever was supposed to be rendered in the container.
  # This way a whole tree of React components is rendered using just a single container / render.
  data <- attr(x, "reactData", exact = TRUE)
  if (is.null(data)) {
    props <- asReactData(addChildrenToProps(x$attribs, x$children))
    ReactData(
      type = "element",
      name = x$name,
      props = dropDeps(props),
      deps = list(getDeps(props), getDeps(x))
    )
  } else data
}

#' @export
asReactData.shiny.tag.function <- function(x) asReactData(x()) # nolint
