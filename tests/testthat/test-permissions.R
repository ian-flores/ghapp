test_that("valid permissions pass validation", {
  valid_perms <- list(contents = "read", issues = "write", metadata = "read")

  # Should not throw an error

  expect_silent(validate_permissions(valid_perms))
  expect_true(validate_permissions(valid_perms))
})

test_that("NULL permissions pass validation", {
  expect_silent(validate_permissions(NULL))
  expect_true(validate_permissions(NULL))
})

test_that("invalid permission names are rejected with helpful error", {
  invalid_perms <- list(invalid_permission = "read", contents = "read")

  expect_error(
    validate_permissions(invalid_perms),
    regexp = "Unknown permission"
  )
})

test_that("invalid access levels are rejected", {
  invalid_levels <- list(contents = "invalid", issues = "write")

  expect_error(
    validate_permissions(invalid_levels),
    regexp = "Invalid access level"
  )
})

test_that("non-list input is rejected", {
  # Character vector instead of list
  expect_error(
    validate_permissions(c(contents = "read")),
    regexp = "must be a named list"
  )

  # Unnamed list
  expect_error(
    validate_permissions(list("read", "write")),
    regexp = "must be a named list"
  )
})
