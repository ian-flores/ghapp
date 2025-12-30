#' Generate a JWT claim signed by a private key
#'
#' @param app_id GitHub App ID
#' @param private_key_path Path to the GitHub App Private Key. Used if
#'   `private_key` is not provided.
#' @param private_key Inline PEM string of the private key. Takes precedence
#'   over `private_key_path` if both are provided.
#'
#' @return Signed JWT with claim to the GitHub App
#'
#' @examples
#' \dontrun{
#' # Using a file path
#' generate_jwt_claim(app_id = "2023", private_key_path = "~/Downloads/key.pem")
#'
#' # Using an inline key
#' generate_jwt_claim(app_id = "2023", private_key = "-----BEGIN RSA PRIVATE KEY-----\n...")
#' }
#'
#' @keywords internal
generate_jwt_claim <- function(app_id, private_key_path = NULL, private_key = NULL) {
  # Use inline key if provided, otherwise read from file
  if (!is.null(private_key) && nzchar(private_key)) {
    key <- openssl::read_key(private_key)
  } else if (!is.null(private_key_path) && nzchar(private_key_path)) {
    key <- openssl::read_key(file = private_key_path)
  } else {
    cli::cli_abort("Either {.arg private_key} or {.arg private_key_path} must be provided.")
  }

  claim <- jose::jwt_claim(iss = app_id, iat = Sys.time() - 60, exp = Sys.time() + 600)

  jwt <- jose::jwt_encode_sig(claim, key = key)

  jwt
}
