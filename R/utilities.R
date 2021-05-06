toJson <- function(
  x, ...,
  auto_unbox = TRUE, json_verbatim = TRUE, # nolint
  Date = "ISO8601", POSIXt = "ISO8601", null = "null", na = "null" # nolint
) jsonlite::toJSON(
  x, ...,
  auto_unbox = auto_unbox, json_verbatim = json_verbatim,
  Date = Date, POSIXt = POSIXt, null = null, na = na
)

addChildrenToProps <- function(props, children) {
  if (length(children) > 0) {
    if ("children" %in% names(props))
      stop("Do not use the 'children' argument and unnamed arguments at the same time")
    if (length(children) == 1) children <- children[[1]]
    props$children <- children
  }
  props
}

reactDataTag <- function(data) {
  stopifnot(inherits(data, "ReactData"))
  htmltools::tagFunction(function() {
    htmltools::attachDependencies(
      htmltools::tags$script(class = "react-data", type = "application/json",
        # The JSON string must be wrapped in HTML()
        # to prevent htmltools from escaping '<', '>' and '&' characters.
        htmltools::HTML(toJson(data))
      ),
      getDeps(data)
    )
  })
}

reactContainer <- function(..., data = NULL) {
  tag <- htmltools::div(class = "react-container", allShinyReactDependencies(), ...)
  if (!is.null(data)) {
    tag <- htmltools::tagAppendChildren(tag,
      reactDataTag(data),
      htmltools::tags$script("jsmodule['@/shiny.react'].findAndRenderReactData()")
    )
  }
  structure(tag, reactData = data)
}

flattenDeps <- function(deps) {
  if (is.null(deps)) return(NULL)
  if (inherits(deps, "html_dependency")) return(list(deps))
  if (inherits(deps, "list")) return(unlist(lapply(deps, flattenDeps), recursive = FALSE))
  stop("Expected a recursive structure built of NULLs, lists and dependencies")
}

getDeps <- function(x) attr(x, "html_dependencies", exact = TRUE)
dropDeps <- function(x) if (!is.null(x)) structure(x, html_dependencies = NULL)
