#' Create a ghapp_token object
#'
#' S3 class constructor for GitHub App installation tokens with metadata.
#'
#' @param token Character string containing the installation access token.
#' @param expires_at POSIXct timestamp when the token expires.
#' @param permissions Named list of granted permissions (optional).
#' @param repositories Character vector of repository names the token is scoped to (optional).
#'
#' @return A `ghapp_token` S3 object containing the token and its metadata.
#'
#' @keywords internal
new_ghapp_token <- function(token, expires_at, permissions = NULL, repositories = NULL) {
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

#' Print method for ghapp_token objects
#'
#' Displays token information without revealing the actual token value.
#'
#' @param x A `ghapp_token` object.
#' @param ... Additional arguments (ignored).
#'
#' @return Invisibly returns the input object.
#'
#' @export
print.ghapp_token <- function(x, ...) {
  cli::cli_h3("GitHub App Installation Token")

  # Token preview (first 8 characters + masked)
  token_preview <- paste0(substr(x$token, 1, 8), "...")
  cli::cli_text("{.strong Token:} {.val {token_preview}}")

  # Expiration
  time_remaining <- difftime(x$expires_at, Sys.time(), units = "mins")
  if (time_remaining > 0) {
    cli::cli_text("{.strong Expires:} {x$expires_at} ({round(time_remaining)} minutes remaining)")
  } else {
    cli::cli_text("{.strong Expires:} {x$expires_at} {.emph (EXPIRED)}")
  }

  # Permissions
  if (!is.null(x$permissions) && length(x$permissions) > 0) {
    cli::cli_text("{.strong Permissions:}")
    cli::cli_ol()
    for (name in names(x$permissions)) {
      cli::cli_li("{name}: {x$permissions[[name]]}")
    }
    cli::cli_end()
  }

  # Repositories
  if (!is.null(x$repositories) && length(x$repositories) > 0) {
    cli::cli_text("{.strong Repositories:} {.val {x$repositories}}")
  }

  invisible(x)
}

#' Convert ghapp_token to character
#'
#' Extracts the token string from a ghapp_token object.
#'
#' @param x A `ghapp_token` object.
#' @param ... Additional arguments (ignored).
#'
#' @return Character string containing the token.
#'
#' @export
as.character.ghapp_token <- function(x, ...) {
  x$token
}
