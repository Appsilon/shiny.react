#
# Function to check reactData object (this avoids having repeated code)
validInput <- function(obj, id, js_accessor) {
  expect_equal(obj$type, "input")
  expect_equal(obj$id, id)
  expect_equal(obj$js_accessor, js_accessor)
  expect_s3_class(obj, "ReactData")
}

test_that("setInput :: returns correct information without js_accessor", {
  result <- triggerEvent("some_id")

  expect_equal(result$type, "event")
  expect_equal(result$id, "some_id")
  expect_s3_class(result, "ReactData")
})


test_that("setInput :: succeeds with valid integer js_accessor", {
  result <- setInput("some_id", 1)
  validInput(result, "some_id", "[1]")

  result <- setInput("some_id2", 0)
  validInput(result, "some_id2", "[0]")
})

test_that("setInput :: fails with invalid index js_accessor (a float)", {
  expect_error(setInput("some_id", 2.2), "Arguments not supported")
  expect_error(setInput("some_id", 1.1), "Arguments not supported")
})

test_that("setInput :: fails with invalid integer js_accessor", {
  regex <- "Arguments not supported :: index '.*' is invalid"
  expect_error(setInput("some_id", -20), regex)
  expect_error(setInput("some_id", -1), regex)
})

test_that("setInput :: succeeds with string as js_accessor", {
  result <- setInput("some_id_str", "[0].target.checked")
  validInput(result, "some_id_str", "[0].target.checked")
})
