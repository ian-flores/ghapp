#' Get the GitHub App Installation Token
#'
#' Generates an installation token for a GitHub App. Supports environment
#' variables for configuration and caches tokens to avoid unnecessary API calls.
#'
#' @param app_id GitHub App ID. Defaults to `GHAPP_APP_ID` environment variable.
#' @param private_key_path Path to the GitHub App Private Key file. Defaults to
#'   `GHAPP_PRIVATE_KEY_PATH` environment variable. Used if `private_key` is not
#'   provided.
#' @param private_key Inline PEM string of the private key. Defaults to
#'   `GHAPP_PRIVATE_KEY` environment variable. Takes precedence over
#'   `private_key_path` if both are provided.
#' @param installation_id Specific installation ID to use. If NULL (default),
#'   uses the first available installation.
#' @param api_url Base URL for the GitHub API. Defaults to `GHAPP_API_URL`
#'   environment variable, or `https://api.github.com` if not set. Use this
#'   parameter for GitHub Enterprise Server installations.
#' @param repositories Character vector of repository names to scope the token to.
#'   If NULL (default), the token has access to all repositories the installation
#'   can access.
#' @param permissions Named list of permissions to request. Names are permission
#'   names (e.g., "contents", "issues") and values are access levels ("read" or
#'   "write"). If NULL (default), uses the installation's default permissions.
#' @param simple If TRUE (default), return just the token string for backward
#'   compatibility. If FALSE, return a `ghapp_token` S3 object with metadata
#'   including expiration time, permissions, and repository scope.
#' @param verbose If TRUE (default), prints the token's permissions. If FALSE,
#'   only returns the token silently.
#'
#' @return If `simple = TRUE`, an installation token (character string) to make
#'   API requests, returned invisibly. If `simple = FALSE`, a `ghapp_token` S3
#'   object containing the token and metadata (expires_at, permissions, repositories).
#'
#' @examples
#' \dontrun{
#' # Using environment variables (recommended)
#' Sys.setenv(GHAPP_APP_ID = "123456")
#' Sys.setenv(GHAPP_PRIVATE_KEY_PATH = "~/Downloads/key.pem")
#' get_github_app_token()
#'
#' # Using explicit arguments
#' get_github_app_token(app_id = "123456", private_key_path = "~/key.pem")
#'
#' # Using an inline key
#' get_github_app_token(app_id = "123456", private_key = "-----BEGIN RSA...")
#'
#' # Using a specific installation
#' get_github_app_token(installation_id = "789012")
#'
#' # Suppress verbose output
#' token <- get_github_app_token(verbose = FALSE)
#'
#' # Get full token object with metadata
#' token_obj <- get_github_app_token(simple = FALSE)
#' token_obj$expires_at
#' token_obj$permissions
#'
#' # Scope token to specific repositories
#' token <- get_github_app_token(repositories = c("my-repo", "another-repo"))
#'
#' # Request specific permissions
#' token <- get_github_app_token(
#'   permissions = list(contents = "read", issues = "write")
#' )
#' }
#'
#' @export
get_github_app_token <- function(
    app_id = Sys.getenv("GHAPP_APP_ID"),
    private_key_path = Sys.getenv("GHAPP_PRIVATE_KEY_PATH"),
    private_key = Sys.getenv("GHAPP_PRIVATE_KEY"),
    installation_id = NULL,
    api_url = Sys.getenv("GHAPP_API_URL", "https://api.github.com"),
    repositories = NULL,
    permissions = NULL,
    simple = TRUE,
    verbose = TRUE
) {
  # Validate app_id
  if (!nzchar(app_id)) {
    cli::cli_abort(c(
      "GitHub App ID is required.",
      "i" = "Set {.envvar GHAPP_APP_ID} or pass {.arg app_id} argument."
    ))
  }

  # Validate that at least one key source is provided
  if (!nzchar(private_key) && !nzchar(private_key_path)) {
    cli::cli_abort(c(
      "A private key is required.",
      "i" = "Set {.envvar GHAPP_PRIVATE_KEY} (inline PEM) or {.envvar GHAPP_PRIVATE_KEY_PATH} (file path),",
      "i" = "or pass {.arg private_key} or {.arg private_key_path} argument."
    ))
  }

  # Validate permissions if provided
  validate_permissions(permissions)

  tryCatch(
    {
      # Generate JWT for API authentication
      jwt <- generate_jwt_claim(
        app_id = app_id,
        private_key_path = if (nzchar(private_key_path)) private_key_path else NULL,
        private_key = if (nzchar(private_key)) private_key else NULL
      )

      # Determine installation ID
      if (is.null(installation_id)) {
        installation <- get_first_installation(jwt, api_url = api_url)
        installation_id <- installation$id
        installation_permissions <- installation$permissions
      } else {
        installation_permissions <- NULL
      }

      # Build cache key including repositories and permissions for scoped tokens
      cache_key <- paste0(app_id, "_", installation_id)
      if (!is.null(repositories)) {
        cache_key <- paste0(cache_key, "_repos:", paste(sort(repositories), collapse = ","))
      }
      if (!is.null(permissions)) {
        perm_str <- paste(names(permissions), unlist(permissions), sep = ":", collapse = ",")
        cache_key <- paste0(cache_key, "_perms:", perm_str)
      }

      cached_token <- cache_get(cache_key)

      if (!is.null(cached_token)) {
        if (verbose) {
          cli::cli_alert_success("Using cached token for installation {.val {installation_id}}")
        }
        if (simple) {
          return(invisible(cached_token))
        } else {
          # For non-simple mode with cached token, we need to return a ghapp_token
          # We don't have the full metadata cached, so fetch fresh
          # Fall through to API call
        }
      }

      # Get new token from API
      token_result <- get_installation_token(
        jwt,
        installation_id,
        api_url = api_url,
        repositories = repositories,
        permissions = permissions
      )

      # Cache the token
      cache_set(cache_key, token_result$token, token_result$expires_at)

      # Determine which permissions to display
      display_permissions <- if (!is.null(token_result$permissions)) token_result$permissions else installation_permissions

      # Display permissions if verbose and available
      if (verbose) {
        if (!is.null(display_permissions)) {
          cli::cli_text("{.emph Your token has the following permissions:}")
          cli::cli_ol()
          for (name in names(display_permissions)) {
            cli::cli_li(paste(name, "-->", display_permissions[[name]]))
          }
          cli::cli_end()
        } else {
          cli::cli_alert_success("Token generated for installation {.val {installation_id}}")
        }

        # Show repository scope if applicable
        if (!is.null(token_result$repositories)) {
          cli::cli_text("{.emph Scoped to repositories:} {.val {token_result$repositories}}")
        }
      }

      if (simple) {
        invisible(token_result$token)
      } else {
        new_ghapp_token(
          token = token_result$token,
          expires_at = token_result$expires_at,
          permissions = token_result$permissions,
          repositories = token_result$repositories
        )
      }
    },
    error = function(e) {
      cli::cli_abort(c(
        "Failed to generate token.",
        "x" = e$message
      ))
    }
  )
}
