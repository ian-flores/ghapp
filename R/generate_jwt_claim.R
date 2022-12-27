#' Generate a JWT claim signed by a private key
#'
#' @param app_id GitHub App ID
#' @param private_key_path Path to the GitHub App Private Key
#'
#' @return Signed JWT with claim to the GitHub App
#'
#' @examples
#' \dontrun{
#' generate_jwt_claim(app_id = "2023", private_key_path = "~/Downloads/key.pem")
#' }
#'
#' @export

generate_jwt_claim <- function(app_id, private_key_path){
  private_key <- openssl::read_key(file = private_key_path)

  claim <- jose::jwt_claim(iss = app_id, iat = Sys.time() - 60, exp = Sys.time() + 600)

  jwt <- jose::jwt_encode_sig(claim, key = private_key)

  return(jwt)
}
