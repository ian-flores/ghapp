# ghapp

<!-- badges: start -->
[![R-CMD-check](https://img.shields.io/badge/R--CMD--check-passing-brightgreen)](https://github.com/ian-flores/ghapp)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
<!-- badges: end -->

Generate installation access tokens for GitHub Apps in R. Designed for CI/CD workflows with support for environment variables, GitHub Enterprise, scoped permissions, and automatic token caching.

## Installation

```r
# install.packages("remotes")
remotes::install_github("ian-flores/ghapp")
```

Requires R >= 4.1.0.

## Quick Start

```r
library(ghapp)

# Using environment variables (recommended for CI/CD)
Sys.setenv(GHAPP_APP_ID = "123456")
Sys.setenv(GHAPP_PRIVATE_KEY_PATH = "~/key.pem")

token <- get_github_app_token()

# Use token for authenticated API calls
httr2::request("https://api.github.com/repos/owner/repo") |>
httr2::req_headers(Authorization = paste("Bearer", token)) |>
httr2::req_perform()
```

## Features

### Environment Variables

Configure credentials via environment variables for seamless CI/CD integration:

| Variable | Description |
|----------|-------------|
| `GHAPP_APP_ID` | GitHub App ID |
| `GHAPP_PRIVATE_KEY_PATH` | Path to private key PEM file |
| `GHAPP_PRIVATE_KEY` | Inline PEM string (for secrets managers) |
| `GHAPP_API_URL` | API URL for GitHub Enterprise |

### Multiple Installations

```r
# List all installations
installations <- get_installations()
print(installations)
#>        id account_login account_type
#> 1 1234567        my-org Organization
#> 2 2345678       my-user         User

# Get token for specific installation
token <- get_github_app_token(installation_id = "2345678")
```

### Token Caching

Tokens are automatically cached and reused until expiration:

```r
token1 <- get_github_app_token()  # Fetches from API
token2 <- get_github_app_token()  # Uses cached token

# Clear cache manually if needed
cache_clear()
```

### GitHub Enterprise

```r
token <- get_github_app_token(
  api_url = "https://github.mycompany.com/api/v3"
)
```

### Scoped Permissions

Request minimal permissions following least-privilege principle:
```r
token <- get_github_app_token(
  repositories = c("repo1", "repo2"),
  permissions = list(contents = "read", issues = "write")
)
```

### Token Metadata

Access token details with the `ghapp_token` S3 class:

```r
token_obj <- get_github_app_token(simple = FALSE)
token_obj$expires_at
token_obj$permissions
as.character(token_obj)  # Extract token string
```

## CI/CD Example (GitHub Actions)

```yaml
- name: Get GitHub App Token
  env:
    GHAPP_APP_ID: ${{ secrets.APP_ID }}
    GHAPP_PRIVATE_KEY: ${{ secrets.APP_PRIVATE_KEY }}
  run: |
    Rscript -e '
      library(ghapp)
      token <- get_github_app_token(verbose = FALSE)
      # Use token for API calls
    '
```

## Documentation

See the [Getting Started vignette](https://ian-flores.github.io/ghapp/articles/getting-started.html) for comprehensive documentation.

## License

Copyright 2022-2024 Voltron Data
Copyright 2024-present Ian Flores Siaca

Licensed under the Apache License, Version 2.0. See [LICENSE.md](LICENSE.md) for details.
