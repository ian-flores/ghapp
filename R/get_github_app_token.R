#' Get the GitHub App Installation Token
#'
#' @param app_id GitHub App ID
#' @param private_key_path Path to the GitHub App Private Key
#' @param verbose If TRUE (default), will print the token and it's permissions.
#' If false, it will only return the token.
#'
#' @return An installation token to make API requests
#'
#' @examples
#' \dontrun{
#' get_github_app_token(app_id, private_key_path)
#' get_github_app_token(app_id, private_key_path, verbose = FALSE)
#' }
#'
#' @export

get_github_app_token <- function(app_id, private_key_path, verbose = TRUE){
  tryCatch({
    jwt <- generate_jwt_claim(app_id, private_key_path)
    installation <- get_first_installation(jwt)
    installation_token <- get_installation_token(jwt, installation$id)

    if (verbose){
      permissions <- installation$permissions

      cli::cli_alert_info("Your token is: {installation_token}")
      cli::cli_text("{.emph Your token has the following permissions}")
      cli::cli_ol()
      for (name in names(permissions)){
        cli::cli_li(paste(name, "-->", permissions[[name]]))
      }
      cli::cli_end()

      invisible(installation_token)
    } else {
      return(installation_token)
    }

  },
  error = function(e){cli::cli_alert_danger("Your token couldn't be generated. Try again.")},
  finally = {})

}
