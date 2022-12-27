#' Get the first installation of the GitHub App
#'
#' @param jwt Signed JWT with claim to the GitHub App
#'
#' @return A list with all the values of the first GitHub App installation
#'
#' @examples
#' \dontrun{
#' get_first_installation(jwt)
#' }
#'

get_first_installation <- function(jwt){
  installation <- httr2::request("https://api.github.com/app/installations") %>%
    httr2::req_headers(Authorization = paste("Bearer", jwt),
                       Accept = "application/vnd.github+json") %>%
    httr2::req_perform() %>%
    httr2::resp_body_json()

  return(installation[[1]])
}
