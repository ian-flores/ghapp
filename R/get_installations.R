#' List all installations of a GitHub App
#'
#' Retrieves all installations for a GitHub App and returns them as a data.frame.
#' This is useful for discovering which organizations or users have installed
#' your GitHub App and what repository access they've granted.
#'
#' @param app_id GitHub App ID. Defaults to `GHAPP_APP_ID` environment variable.
#' @param private_key_path Path to the GitHub App Private Key file. Defaults to
#'   `GHAPP_PRIVATE_KEY_PATH` environment variable. Used if `private_key` is not
#'   provided.
#' @param private_key Inline PEM string of the private key. Defaults to
#'   `GHAPP_PRIVATE_KEY` environment variable. Takes precedence over
#'   `private_key_path` if both are provided.
#' @param api_url Base URL for the GitHub API. Defaults to `GHAPP_API_URL`
#'   environment variable, or `https://api.github.com` if not set. Use this
#'   parameter for GitHub Enterprise Server installations.
#'
#' @return A data.frame with the following columns:
#' \describe{
#'   \item{id}{Numeric installation ID}
#'   \item{account_login}{Character username or organization name}
#'   \item{account_type}{Character indicating "User" or "Organization"}
#'   \item{repository_selection}{Character indicating "all" or "selected"}
#' }
#' Returns an empty data.frame with correct column types if no installations exist.
#'
#' @examples
#' \dontrun{
#' # Using environment variables (recommended)
#' Sys.setenv(GHAPP_APP_ID = "123456")
#' Sys.setenv(GHAPP_PRIVATE_KEY_PATH = "~/Downloads/key.pem")
#' installations <- get_installations()
#'
#' # Using explicit arguments
#' installations <- get_installations(
#'   app_id = "123456",
#'   private_key_path = "~/key.pem"
#' )
#'
#' # Filter to organizations only
#' orgs <- installations[installations$account_type == "Organization", ]
#' }
#'
#' @export
get_installations <- function(
    app_id = Sys.getenv("GHAPP_APP_ID"),
    private_key_path = Sys.getenv("GHAPP_PRIVATE_KEY_PATH"),
    private_key = Sys.getenv("GHAPP_PRIVATE_KEY"),
    api_url = Sys.getenv("GHAPP_API_URL", "https://api.github.com")
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

  # Generate JWT for API authentication
  jwt <- generate_jwt_claim(
    app_id = app_id,
    private_key_path = if (nzchar(private_key_path)) private_key_path else NULL,
    private_key = if (nzchar(private_key)) private_key else NULL
  )

  # Call GitHub API to list installations
  installations <- httr2::request(paste0(api_url, "/app/installations")) |>
    httr2::req_headers(
      Authorization = paste("Bearer", jwt),
      Accept = "application/vnd.github+json"
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  # Handle empty installations list
  if (length(installations) == 0) {
    return(data.frame(
      id = numeric(0),
      account_login = character(0),
      account_type = character(0),
      repository_selection = character(0),
      stringsAsFactors = FALSE
    ))
  }

  # Extract relevant fields into a data.frame
  installations |>
    lapply(\(inst) {
      data.frame(
        id = inst$id,
        account_login = inst$account$login,
        account_type = inst$account$type,
        repository_selection = inst$repository_selection,
        stringsAsFactors = FALSE
      )
    }) |>
    do.call(what = rbind)
}
