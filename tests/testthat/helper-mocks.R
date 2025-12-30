# Helper functions for ghapp tests

#' Create a mock JWT response
#'
#' Returns a mock JWT token string for testing.
#'
#' @return Character string representing a mock JWT
mock_jwt <- function() {

"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2MTYyMzkwMjIsImV4cCI6MTYxNjIzOTYyMiwiaXNzIjoiMTIzNDU2In0.signature"
}

#' Create mock installation data
#'
#' Returns a list representing a GitHub App installation.
#'
#' @param id Installation ID (default: 12345678)
#' @param account_login Account login name (default: "test-org")
#' @return List with installation data
mock_installation <- function(id = 12345678, account_login = "test-org") {
  list(
    id = id,
    account = list(
      login = account_login,
      id = 1234,
      type = "Organization"
    ),
    app_id = 123456,
    target_type = "Organization",
    permissions = list(
      contents = "read",
      metadata = "read"
    ),
    events = list("push", "pull_request"),
    created_at = "2024-01-01T00:00:00Z",
    updated_at = "2024-01-01T00:00:00Z"
  )
}

#' Create mock token response
#'
#' Returns a list representing a GitHub installation token response.
#'
#' @param token Token string (default: "ghs_test_token_abc123")
#' @param expires_at ISO 8601 timestamp (default: 1 hour from now)
#' @param permissions Named list of permissions
#' @param repositories Character vector of repository names
#' @return List with token response data
mock_token_response <- function(
    token = "ghs_test_token_abc123",
    expires_at = NULL,
    permissions = list(contents = "read", metadata = "read"),
    repositories = NULL
) {
  if (is.null(expires_at)) {
    expires_at <- format(Sys.time() + 3600, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  }

  response <- list(
    token = token,
    expires_at = expires_at,
    permissions = permissions
  )

  if (!is.null(repositories)) {
    response$repositories <- lapply(repositories, function(name) {
      list(
        id = sample(1000000:9999999, 1),
        name = name,
        full_name = paste0("test-org/", name)
      )
    })
  }

  response
}

#' Clear the ghapp cache for testing
#'
#' Ensures the cache is empty before/after tests.
clear_test_cache <- function() {
  ghapp::cache_clear()
}
