library(mockery)

a_package_name <- "my.react.package"
a_component_name <- "MyComponent"
a_tag <- htmltools::tag(a_component_name, "contents")

test_that("input_class_name returns a valid CSS class name", {
  name <- input_class_name(a_package_name, a_component_name)

  expect_equal(name, "my-react-package-MyComponent")
})

test_that("mark_as_react_tag adds a shiny.react.tag class", {
  result <- mark_as_react_tag(a_package_name, a_tag)

  expect_s3_class(result, shiny_react_tag_class)
})

test_that("mark_as_react_tag preserves existing classes", {
  a_class <- "my_class"
  tag_with_class <- structure(a_tag, class = a_class)

  result <- mark_as_react_tag(a_package_name, tag_with_class)

  expect_s3_class(result, a_class)
})

test_that("mark_as_react_tag adds packageName as attribute", {
  result <- mark_as_react_tag(a_package_name, a_tag)

  expect_identical(result$packageName, a_package_name)
})

test_that("needs_shiny_component_wrapper is false for HTML tags", {
  tag <- htmltools::tags$div()

  result <- needs_shiny_component_wrapper(tag)

  expect_false(result)
})

test_that("needs_shiny_component_wrapper is true for textInput", {
  tag <- shiny::textInput("an id", "a label")

  result <- needs_shiny_component_wrapper(tag)

  expect_true(result)
})

test_that("needs_shiny_component_wrapper is true for leafletOutput's internal node", {
  tag <- leaflet::leafletOutput("an id")[[1]]

  result <- needs_shiny_component_wrapper(tag)

  expect_true(result)
})

test_that("needs_shiny_component_wrapper is true for textOutput", {
  tag <- shiny::textOutput("an id")

  result <- needs_shiny_component_wrapper(tag)

  expect_true(result)
})

test_that("needs_shiny_component_wrapper is true for uiOutput", {
  tag <- shiny::uiOutput("an id")

  result <- needs_shiny_component_wrapper(tag)

  expect_true(result)
})

test_that("prepare_tags_for_serialization keeps html tags", {
  tag <- htmltools::tags$div()

  result <- prepare_tags_for_serialization(tag)

  expect_equal(tag, tag)
})

test_that("prepare_tags_for_serialization removes html dependencies from tag lists", {
  tag <- htmltools::tags$div(
    html_dependency_react(),
    htmltools::tags$div()
  )

  result <- prepare_tags_for_serialization(tag)

  expect_equal(result, htmltools::tags$div(htmltools::tags$div()))
})

test_that("prepare_tags_for_serialization adds a ShinyComponentWrapper around Shiny components", {
  tag <- shiny::textOutput("test")

  result <- prepare_tags_for_serialization(tag)

  expect_equal(result, ShinyComponentWrapper(tag))
})

test_that("prepare_tags_for_serialization does not add a second ShinyComponentWrapper around Shiny components", {
  tag <- ShinyComponentWrapper(shiny::textOutput("test"))

  result <- prepare_tags_for_serialization(tag)

  expect_equal(result, tag)
})

test_that("serialize_shiny_react_tags renders attributes wrapped in JS(...) as raw JS code", {
  a_js_code <- "abc"
  tag <- htmltools::tags$div(onClick = JS(a_js_code))

  result <- serialize_shiny_react_tags(tag, pretty_print = FALSE)

  expected <- paste0('{"name":"div","attribs":{"onClick":', a_js_code, '},"children":[]}')
  expect_equal(as.character(result), expected)
})

test_that("serialize_shiny_react_tags renders attributes not wrapped in JS(...) as JSON", {
  an_attribute <- "abc"
  tag <- htmltools::tags$div(onClick = an_attribute)

  result <- serialize_shiny_react_tags(tag, pretty_print = FALSE)

  expected <- paste0('{"name":"div","attribs":{"onClick":"', an_attribute, '"},"children":[]}')
  expect_equal(as.character(result), expected)
})

test_that("rename_attrib_if_present correctly renames an attribute", {
  a_tag <- htmltools::tags$div(class = "some-class")

  result <- rename_attrib_if_present(a_tag, "class", "className")

  expect_identical(result$attribs[["class"]], NULL)
  expect_identical(result$attribs[["className"]], "some-class")
})

test_that("rename_attrib_if_present warns when overwriting an attribute", {
  a_tag <- htmltools::tags$div(class = "some-class", className = "other-class")

  expect_warning(rename_attrib_if_present(a_tag, "class", "className"))
})

test_that("withReact adds a ShinyComponentWrapper around tags", {
  # given
  a_result <- "result"
  an_id <- "some_id"
  a_tag <- htmltools::tags$div()

  make_react_render_tags_mock <- mock(a_result)
  stub(withReact, "make_react_render_tags", make_react_render_tags_mock)
  stub(withReact, "generate_random_container_id", an_id)

  # when
  result <- withReact(a_tag)

  # then
  serialized_text <- serialize_shiny_react_tags(ShinyComponentWrapper(a_tag))
  expected_serialized <- structure(serialized_text, class = "json")
  expect_args(make_react_render_tags_mock, 1, expected_serialized, NULL, an_id)
  expect_equal(result, a_result)
})
