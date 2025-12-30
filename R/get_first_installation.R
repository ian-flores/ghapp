#' Get the first installation of the GitHub App
#'
#' @param jwt Signed JWT with claim to the GitHub App
#' @param api_url Base URL for the GitHub API. Defaults to `GHAPP_API_URL`
#'   environment variable, or `https://api.github.com` if not set.
#'
#' @return A list with all the values of the first GitHub App installation
#'
#' @examples
#' \dontrun{
#' get_first_installation(jwt)
#' }
#'
#' @keywords internal
get_first_installation <- function(
    jwt,
    api_url = Sys.getenv("GHAPP_API_URL", "https://api.github.com")
) {
  installation <- httr2::request(paste0(api_url, "/app/installations")) |>
    httr2::req_headers(
      Authorization = paste("Bearer", jwt),
      Accept = "application/vnd.github+json"
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  installation[[1]]
}
