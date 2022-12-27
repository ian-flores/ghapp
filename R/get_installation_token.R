#' Get the installation token to make API requests
#'
#' @param jwt Signed JWT with claim to the GitHub App
#' @param installation_id The id of the installation from which we want to obtain the token
#'
#' @return An installation token to make API requests
#'
#' @examples
#' \dontrun{
#' get_installation_token(jwt, installation$id)
#' }
#'
#' @export

get_installation_token <- function(jwt, installation_id){
  installation_token <- httr2::request(paste0("https://api.github.com/app/installations/", installation_id, "/access_tokens")) %>%
    httr2::req_headers(Authorization = paste("Bearer", jwt),
                       Accept = "application/vnd.github+json") %>%
    httr2::req_method("POST") %>%
    httr2::req_perform() %>%
    httr2::resp_body_json()

  return(installation_token$token)
}
