# ghapp Improvement Plan

## Phase 1: CI/CD & Core Features

### 1.1 Environment Variable Support
```r
# In get_github_app_token.R
get_github_app_token <- function(
  app_id = Sys.getenv("GHAPP_APP_ID"),
  private_key_path = Sys.getenv("GHAPP_PRIVATE_KEY_PATH"),
  private_key = Sys.getenv("GHAPP_PRIVATE_KEY"),  # Direct key content
  verbose = TRUE
) {
  # Allow either path or direct key content
  if (!is.null(private_key) && private_key != "") {
    key <- openssl::read_key(private_key)
  } else {
    key <- openssl::read_key(file = private_key_path)
  }
  ...
}
```

### 1.2 Select Specific Installation
```r
# New function: get_installations.R
#' List all installations of the GitHub App
#' @export
get_installations <- function(app_id, private_key_path) {
  jwt <- generate_jwt_claim(app_id, private_key_path)
  httr2::request("https://api.github.com/app/installations") %>%
    httr2::req_headers(Authorization = paste("Bearer", jwt)) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json()
}

# Update get_github_app_token to accept installation_id parameter
get_github_app_token <- function(
  app_id, private_key_path,
  installation_id = NULL,  # NULL = first installation
  ...
)
```

### 1.3 Token Caching
```r
# New file: cache.R
.ghapp_cache <- new.env(parent = emptyenv())

cache_token <- function(key, token, expires_at) {
  .ghapp_cache[[key]] <- list(token = token, expires_at = expires_at)
}

get_cached_token <- function(key) {
  cached <- .ghapp_cache[[key]]
  if (!is.null(cached) && Sys.time() < cached$expires_at - 60) {
    return(cached$token)
  }
  NULL
}
```

## Phase 2: Enterprise & Scoping

### 2.1 GitHub Enterprise Support
```r
get_github_app_token <- function(
  ...,
  api_url = Sys.getenv("GHAPP_API_URL", "https://api.github.com")
)
```

### 2.2 Scoped Permissions
```r
get_github_app_token <- function(
  ...,
  repositories = NULL,  # Character vector of repo names
  permissions = NULL    # Named list: list(contents = "read", issues = "write")
) {
  # Pass to installation token request body
  body <- list()
  if (!is.null(repositories)) body$repositories <- repositories
  if (!is.null(permissions)) body$permissions <- permissions

  httr2::req_body_json(body)
}
```

### 2.3 Return Token Metadata
```r
#' @return A list with token, expires_at, and permissions (or just token if simple=TRUE)
get_github_app_token <- function(..., simple = FALSE) {
  ...
  if (simple) {
    return(invisible(token))
  }
  structure(
    list(
      token = token,
      expires_at = expires_at,
      permissions = permissions,
      repositories = repositories
    ),
    class = "ghapp_token"
  )
}

#' @export
print.ghapp_token <- function(x, ...) {
  cli::cli_text("GitHub App Token")
  cli::cli_text("Expires: {x$expires_at}")
  ...
}
```

## Phase 3: CRAN Ready

### 3.1 Replace magrittr with native pipe
- Remove magrittr from Imports
- Delete utils-pipe.R
- Replace `%>%` with `|>` throughout
- Update DESCRIPTION: Depends: R (>= 4.1.0)

### 3.2 Add Tests
```r
# tests/testthat/test-jwt.R
test_that("JWT claim has correct structure", {
  skip_if_not(file.exists("test-key.pem"))
  jwt <- generate_jwt_claim("123", "test-key.pem")
  parts <- strsplit(jwt, "\\.")[[1]]
  expect_length(parts, 3)
})

# tests/testthat/test-cache.R
test_that("token caching works", {
  cache_token("test", "token123", Sys.time() + 600)
  expect_equal(get_cached_token("test"), "token123")
})
```

### 3.3 Documentation Updates
- Add vignette: `vignettes/getting-started.Rmd`
- Update README with badges, more examples
- Add NEWS.md for changelog
- Add pkgdown site configuration

### 3.4 DESCRIPTION Updates
```
Package: ghapp
Version: 0.2.0
Depends: R (>= 4.1.0)
Imports:
    cli,
    httr2,
    jose,
    openssl
Suggests:
    testthat (>= 3.0.0),
    withr
Config/testthat/edition: 3
URL: https://github.com/ian-flores/ghapp
BugReports: https://github.com/ian-flores/ghapp/issues
```

## Implementation Order

1. [ ] Environment variable support
2. [ ] Select specific installation
3. [ ] GitHub Enterprise support
4. [ ] Return token metadata
5. [ ] Scoped permissions
6. [ ] Token caching
7. [ ] Replace magrittr with native pipe
8. [ ] Add tests
9. [ ] Update documentation
10. [ ] CRAN submission prep
