shiny_react_tag_class <- "shiny.react.tag"
shiny_react_tag_list_class <- "shiny.react.tag.list"

#' Rename controlled attributes to uncontrolled
#'
#' @details
#' For certain tags, some attributes (e.g. `<input value="">`) make a component controlled in React.
#' This happens even if they are inserted using dangerouslySetInnerHTML.
#' We want the components to be uncontrolled, because we observe values via Shiny bindings.
#' Therefore we need to rename the attributes, e.g. value -> defaultValue.
#' Otherwise the value cannot be changed by the user, because React resets it to the initial value.
#'
#' See for details:
#' - https://reactjs.org/docs/uncontrolled-components.html
#' - https://goshakkk.name/controlled-vs-uncontrolled-inputs-react/
#'
#' @param tag HTML tag to be processed.
#'
#' @md
rename_attribs_to_uncontrolled <- function(tag) {
  if (tag$name == "input") {
    # For textarea assigning contents to defaultValue handled by html-react-parser on the client side
    # For select, defaultValue is present in React but not in HTML, so we don't expect it to appear.

    if (!is.null(tag$type) && (tag$type %in% c("radio", "checkbox"))) {
      tag <- rename_attrib_if_present(tag, "checked", "defaultChecked")
    } else {
      # All other inputs, including type="text"
      tag <- rename_attrib_if_present(tag, "value", "defaultValue")
    }
  }
  tag
}

prepare_tag_attribs <- function(tag) {
  fix_attribute <- function(attribute) {
    if (inherits(attribute, "shiny.tag") || inherits(attribute, "shiny.tag.list")) {
      prepare_tags_for_serialization(attribute, is_in_attribute = TRUE)
    } else {
      attribute
    }
  }
  tag$attribs <- lapply(tag$attribs, fix_attribute)
  tag
}

make_custom_shiny_react_tag <- function(type, content) {
  list("$$shiny_react_type" = type, content = content)
}

mark_js_attribs_as_raw_json <- function(attribs_list) {
  fix_attribute <- function(attribute) {
    # htmlwidgets::JS sets a 'JS_EVAL' class.
    if (inherits(attribute, "JS_EVAL")) {
      # Pass the JS code as a string inside a special tag marked as "javascript" type, that will be run on the client.
      make_custom_shiny_react_tag("javascript", attribute[[1]])
    } else {
      attribute
    }
  }
  lapply(attribs_list, fix_attribute)
}

#' Should return TRUE iff a tag should be wrapped in a ShinyComponentWrapper
#'
#' @param tag HTML tag.
needs_shiny_component_wrapper <- function(tag) {
  class_matchers <- c(
    "shiny\\-input\\-container",
    "html\\-widget\\-output",
    "shiny\\-[a-zA-Z]*\\-output"
  )
  regex <- paste(class_matchers, collapse = "|") # nolint
  is.list(tag$attribs) && isTRUE(grepl(glue::glue("\\b({regex})\\b"), tag$attribs$class, perl = TRUE))
}

#' This function does several things needed before a tag tree can be transformed into JSON:
#' 1. Remove all html_dependency nodes.
#' 2. Rename some attributes in React nodes to ensure they do not become controlled components.
#' 3. Remove names so that lists serialize into arrays and not objects.
#' 4. Add ShinyComponentWrapper around Shiny inputs and outputs
#'
#' @param tags tags to be processed.
#' @param is_in_attribute should be set to true if the processed tags are inside another components attribute
prepare_tags_for_serialization <- function(tags, is_in_attribute = FALSE) { # nolint
  fix_tags <- function(tag, parent = NULL) {
    if (inherits(tag, shiny_react_tag_class)) {
      tag <- prepare_tag_attribs(tag)
    }
    if (inherits(tag, "shiny.tag")) {
      if (!inherits(tag, shiny_react_tag_class) & !inherits(tag, shiny_react_tag_list_class)) {
        tag <- rename_attribs_to_uncontrolled(tag)
        not_yet_wrapped <- is.null(parent) || parent$name != "ShinyComponentWrapper"
        if (!is_in_attribute && needs_shiny_component_wrapper(tag) && not_yet_wrapped) {
          tag <- ShinyComponentWrapper(tag)
        }
      }
      tag$attribs <- mark_js_attribs_as_raw_json(tag$attribs)
      tag$children <- lapply(tag$children, function(t) {
        fix_tags(t, tag)
      })
      tag$children <- Filter(Negate(is.null), tag$children)
      names(tag$children) <- NULL # Needed for lists to serialize into arrays not objects with numeric keys.
    }

    if (inherits(tag, "list")) {
      tag <- lapply(tag, function(t) {
        fix_tags(t, parent)
      })
      tag <- Filter(Negate(is.null), tag)
      names(tag) <- NULL # Needed for lists to serialize into arrays not objects with numeric keys.
      tag <- make_custom_shiny_react_tag("list", tag)
    }

    if (inherits(tag, "html_dependency")) { # Dependencies are collected in a separate pass.
      return(NULL)
    }

    if (length(tag) == 0) {
      return(NULL)
    }

    tag
  }

  fix_tags(tags)
}

#' Serialize \code{JS}-wrapped attributes directly into the representation to be executed on the client.
#'
#' @param tags tags to be processed.
#' @param pretty_print If TRUE, the tags representation will be sent to the client in a readable format.
serialize_shiny_react_tags <- function(tags, pretty_print = FALSE) {
  fixed_tags <- prepare_tags_for_serialization(tags)
  jsonlite::toJSON(fixed_tags, force = TRUE, auto_unbox = TRUE, json_verbatim = TRUE, pretty = pretty_print)
}

generate_random_container_id <- function() {
  paste(sample(c(letters[1:6], 0:9), 30, replace = TRUE), collapse = "")
}

make_react_render_tags <- function(serialized_tags, dependencies, target_id) {
  code <- glue::glue(
    "nodes = {serialized_tags};\n\n",
    "window.ShinyReact.render(nodes, '{target_id}')"
  )

  shiny::tagList(
    dependencies,
    shiny::tags$div(id = target_id),
    shiny::tags$script(htmltools::HTML(code))
  )
}

prepare_for_rendering <- function(...) {
  mixed_tags <- ShinyComponentWrapper(...)
  dependencies <- c(
    all_shiny_react_dependencies(),
    htmltools::findDependencies(mixed_tags)
  )

  serialized <- serialize_shiny_react_tags(mixed_tags, pretty_print = is_debug_mode())

  logger::log_debug("Tags representation prepared for rendering:\n\n{serialized}")

  list(tags_json = serialized, dependencies = dependencies)
}

#' Use arbitrary React components and props in R.
#'
#' Wrap your tags with this function to enable using a mix of HTML and React tags.
#' It will create a `<div>` and `<script>` tags on the client. The script will render tags inside the div using React.
#'
#' Attributes wrapped in \code{JS(...)} (originally from `htmlwidgets`) will be passed directly as JS code.
#' It will be executed when the tags representation is received on the client, so usually they should be functions.
#'
#' This function is named in camelCase for consistency with Shiny naming convention.
#'
#' @param ... One or more tag objects which can be a mix of Shiny (htmltools) and React tags.
#'
#' @export
withReact <- function(...) { # nolint
  id <- generate_random_container_id()

  serialized <- prepare_for_rendering(...)
  make_react_render_tags(serialized$tags_json, serialized$dependencies, id)
}

rename_attrib_if_present <- function(tag, from_name, to_name) {
  if (from_name %in% names(tag$attribs)) {
    if (to_name %in% names(tag$attribs)) {
      warning(glue::glue("{tag$name}: renaming attribute {from_name} to {to_name} will overwrite its value"))
    }
    tag$attribs[[to_name]] <- tag$attribs[[from_name]]
    tag$attribs[[from_name]] <- NULL
  }
  tag
}


#' Mark as React tag
#'
#' Mark an object as a React tag to be rendered on the client using React.
#' The component is expected to be available in \code{window[package_name][componentName]} on the client.
#'
#' @param package_name Where to find the component on the client.
#' @param component Component's name
#'
#' @export
mark_as_react_tag <- function(package_name, component) {
  component$packageName <- package_name # nolint
  component[["$$shiny_react_type"]] <- "react_tag"
  structure(component, class = c(shiny_react_tag_class, oldClass(component)))
}

react_tag_list <- function(from_list) {
  temp_tag_list <- htmltools::tagList(from_list)
  structure(temp_tag_list, class = c(shiny_react_tag_list_class, oldClass(temp_tag_list)))
}
