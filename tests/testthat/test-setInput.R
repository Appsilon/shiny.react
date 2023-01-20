

valid_input <- function(obj, argIdx) {
  expect_equal(obj$type, "input")
  expect_equal(obj$argIdx, argIdx)
  expect_s3_class(obj, "ReactData")
}

test_that("setInput :: returns correct information without argIdx", {
  result <- setInput("some_id")
  valid_input(result, 0)
})


test_that("setInput :: returns correct information with valid integer argIdx", {
  result <- setInput("some_id", 2)
  valid_input(result, 1)

  result <- setInput("some_id", 1)
  valid_input(result, 0)
})

test_that("setInput :: returns correct information with invalid float argIdx", {
  expect_error(setInput("some_id", 2.2), "Arguments not supported")
  expect_error(setInput("some_id", 1.1), "Arguments not supported")
})

test_that("setInput :: returns correct information with invalid integer argIdx", {
  expect_error(setInput("some_id", 0), "Arguments not supported.*index is invalid")
  expect_error(setInput("some_id", -1), "Arguments not supported.*index is invalid")
})

test_that("setInput :: returns correct information with string as argIdx", {
  result <- setInput("some_id", "[0].target.checked")
  valid_input(result, NULL)
  expect_identical(result$ancestor, "[0].target.checked")
})

