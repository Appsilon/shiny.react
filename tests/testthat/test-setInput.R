library(testthat)

validInput <- function(obj, argIdx) {
  expect_equal(obj$type, "input")
  expect_equal(obj$argIdx, argIdx)
  expect_s3_class(obj, "ReactData")
}

test_that("setInput :: returns correct information without argIdx", {
  result <- setInput("some_id")
  validInput(result, 0)
})


test_that("setInput :: returns correct information with valid integer argIdx", {
  result <- setInput("some_id", 2)
  validInput(result, 1)

  result <- setInput("some_id", 1)
  validInput(result, 0)
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
  validInput(result, NULL)
  expect_identical(result$accessor, "[0].target.checked")
})
