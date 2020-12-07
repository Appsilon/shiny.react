create_react_shiny_input <- function(input_id,
                                     class,
                                     dependencies,
                                     default = NULL,
                                     configuration = list(),
                                     container = htmltools::tags$div) {
  if (length(dependencies) < 1) stop("Must include at least one HTML dependency.")
  value <- shiny::restoreInput(id = input_id, default = default)

  # These arguments need to be passed as strings, because we assign them to a div element, not a React element.
  # Otherwise they get added to DOM as <div value="[object Object]">
  json_value <- as.character(jsonlite::toJSON(list(value = value), auto_unbox = TRUE, null = "null"))
  configuration_json <- as.character(jsonlite::toJSON(configuration, auto_unbox = TRUE, null = "null"))

  element <- container(
    id = input_id,
    class = class,
    `data-value` = json_value,
    `data-configuration` = configuration_json
  )

  if (!is.null(dependencies)) {
    element <- htmltools::attachDependencies(element, dependencies)
  }

  element
}

#' Returns a CSS class name used to select DOM elements when installing Shiny input bindings.
#' It must be indentical to the name returned by `inputClassName()` in `shiny-react.jsx`.
#'
#' @param package_name Name of the R package where the component can be found
#' @param component_name Name of the component
input_class_name <- function(package_name, component_name) {
  package_name <- gsub(".", "-", package_name, fixed = TRUE)
  paste0(package_name, "-", component_name)
}

#' Make Shiny input
#'
#' A helper which can be used to define a function behaving
#' just as Shiny input functions do.
#'
#' @param html_dependencies Dependencies to be included with this input
#' @param package_name Name of the R package where the component can be found
#' @param component_name Name of the React component
#' @param default_value Initial value for the input
#'
#' @export
make_input <- function(html_dependencies, package_name, component_name, default_value = "") {
  function(input_id, value = default_value, ...) {
    configuration <- rlang::dots_list(...)
    create_react_shiny_input(
      input_id = input_id,
      class = input_class_name(package_name, component_name),
      dependencies = shiny::tagList(html_dependency_shiny_react(), html_dependencies),
      default = value,
      configuration = prepare_input_configuration(configuration),
      container = htmltools::tags$span
    )
  }
}

prepare_input_configuration <- function(configuration) {
  mark_js_attribs_as_raw_json(configuration)
}

#' Update Shiny input
#'
#' A generic function used to update inputs defined with \link{make_input}.
#'
#' @param session The session object passed to function given to shinyServer
#' @param input_id The id of the input object.
#' @param value The value to set for the input object. If NULL, value will be unchanged.
#' @param ... Additional parameters for the input to be updated. If empty, parameters will be unchanged.
#'
#' @export
update_input <- function(session, input_id, value = NULL, ...) {
  configuration <- rlang::dots_list(...)
  message <- list()
  if (!is.null(value)) message$value <- value
  if (length(configuration) > 0) message$configuration <- prepare_input_configuration(configuration)
  session$sendInputMessage(input_id, message)
}
