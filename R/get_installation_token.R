#' Get the installation token to make API requests
#'
#' @param jwt Signed JWT with claim to the GitHub App
#' @param installation_id The id of the installation from which we want to obtain the token
#' @param api_url Base URL for the GitHub API. Defaults to `GHAPP_API_URL`
#'   environment variable, or `https://api.github.com` if not set.
#' @param repositories Character vector of repository names to scope the token to.
#'   If NULL (default), the token has access to all repositories the installation
#'   can access.
#' @param permissions Named list of permissions to request. Names are permission
#'   names (e.g., "contents", "issues") and values are access levels ("read" or
#'   "write"). If NULL (default), uses the installation's default permissions.
#'
#' @return A list with:
#' \describe{
#'   \item{token}{Character string containing the installation access token}
#'   \item{expires_at}{POSIXct timestamp when the token expires}
#'   \item{permissions}{Named list of granted permissions (if returned by API)}
#'   \item{repositories}{Character vector of repository names (if scoped)}
#' }
#'
#' @examples
#' \dontrun{
#' # Basic usage
#' result <- get_installation_token(jwt, installation$id)
#' result$token
#' result$expires_at
#'
#' # With scoped permissions
#' result <- get_installation_token(
#'   jwt,
#'   installation$id,
#'   permissions = list(contents = "read", issues = "write")
#' )
#'
#' # With repository scope
#' result <- get_installation_token(
#'   jwt,
#'   installation$id,
#'   repositories = c("my-repo", "another-repo")
#' )
#' }
#'
#' @keywords internal
get_installation_token <- function(
    jwt,
    installation_id,
    api_url = Sys.getenv("GHAPP_API_URL", "https://api.github.com"),
    repositories = NULL,
    permissions = NULL
) {
  # Validate permissions if provided
  validate_permissions(permissions)

  # Build request
  req <- httr2::request(paste0(api_url, "/app/installations/", installation_id, "/access_tokens")) |>
    httr2::req_headers(
      Authorization = paste("Bearer", jwt),
      Accept = "application/vnd.github+json"
    ) |>
    httr2::req_method("POST")

  # Add body if repositories or permissions are specified
  body <- list()
  if (!is.null(repositories)) {
    body$repositories <- as.list(repositories)
  }
  if (!is.null(permissions)) {
    body$permissions <- permissions
  }

  if (length(body) > 0) {
    req <- req |> httr2::req_body_json(body)
  }

  response <- req |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  # Extract repository names if present
  repo_names <- NULL
  if (!is.null(response$repositories)) {
    repo_names <- vapply(response$repositories, function(r) r$name, character(1))
  }

  list(
    token = response$token,
    expires_at = as.POSIXct(response$expires_at, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    permissions = response$permissions,
    repositories = repo_names
  )
}
