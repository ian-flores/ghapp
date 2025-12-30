test_that("new_ghapp_token() creates object with correct class", {
  token_string <- "ghs_test_token_abc123"
  expires_at <- Sys.time() + 3600
  permissions <- list(contents = "read")
  repositories <- c("repo1", "repo2")

  token_obj <- new_ghapp_token(
    token = token_string,
    expires_at = expires_at,
    permissions = permissions,
    repositories = repositories
  )

  expect_s3_class(token_obj, "ghapp_token")
  expect_equal(token_obj$token, token_string)
  expect_equal(token_obj$expires_at, expires_at)
  expect_equal(token_obj$permissions, permissions)
  expect_equal(token_obj$repositories, repositories)
})

test_that("new_ghapp_token() works with minimal arguments", {
  token_string <- "ghs_minimal_token"
  expires_at <- Sys.time() + 3600

  token_obj <- new_ghapp_token(
    token = token_string,
    expires_at = expires_at
  )

  expect_s3_class(token_obj, "ghapp_token")
  expect_equal(token_obj$token, token_string)
  expect_null(token_obj$permissions)
  expect_null(token_obj$repositories)
})

test_that("as.character() extracts token string", {
  token_string <- "ghs_extract_me"
  expires_at <- Sys.time() + 3600

  token_obj <- new_ghapp_token(
    token = token_string,
    expires_at = expires_at
  )

  extracted <- as.character(token_obj)

  expect_equal(extracted, token_string)
  expect_type(extracted, "character")
})

test_that("print() doesn't error", {
  token_string <- "ghs_print_test_token"
  expires_at <- Sys.time() + 3600
  permissions <- list(contents = "read", issues = "write")

  token_obj <- new_ghapp_token(
    token = token_string,
    expires_at = expires_at,
    permissions = permissions
  )

  # print() should return invisibly without error
  expect_no_error(print(token_obj))
  expect_invisible(print(token_obj))
})

test_that("print() works with expired token", {
  token_string <- "ghs_expired_token"
  expires_at <- Sys.time() - 3600  # Expired 1 hour ago

  token_obj <- new_ghapp_token(
    token = token_string,
    expires_at = expires_at
  )

  # Should handle expired token without error
  expect_no_error(print(token_obj))
})

test_that("print() works with repositories", {
  token_string <- "ghs_repo_token"
  expires_at <- Sys.time() + 3600
  repositories <- c("repo1", "repo2", "repo3")

  token_obj <- new_ghapp_token(
    token = token_string,
    expires_at = expires_at,
    repositories = repositories
  )

  expect_no_error(print(token_obj))
})
