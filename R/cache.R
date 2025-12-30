#' Token Cache Management
#'
#' Functions to manage cached GitHub App installation tokens.
#'
#' @name cache
#' @keywords internal
NULL

# Package-level cache environment
.ghapp_cache <- new.env(parent = emptyenv())

#' Get a cached token
#'
#' Retrieves a token from the cache if it exists and is not expired.
#'
#' @param key Cache key in format `{app_id}_{installation_id}`
#'
#' @return The cached token if valid, or NULL if expired/missing
#'
#' @examples
#' \dontrun{
#' token <- cache_get("12345_67890")
#' }
#'
#' @keywords internal
cache_get <- function(key) {
  if (!exists(key, envir = .ghapp_cache)) {
    return(NULL)
  }

  cached <- get(key, envir = .ghapp_cache)

  # Check if token has expired
  if (Sys.time() >= cached$expires_at) {
    # Remove expired token
    rm(list = key, envir = .ghapp_cache)
    return(NULL)
  }

  cached$token
}

#' Set a token in the cache
#'
#' Stores a token in the cache with its expiration time.
#'
#' @param key Cache key in format `{app_id}_{installation_id}`
#' @param token The token string to cache
#' @param expires_at POSIXct timestamp when the token expires
#'
#' @return Invisibly returns the token
#'
#' @examples
#' \dontrun{
#' cache_set("12345_67890", "ghs_xxx", Sys.time() + 3600)
#' }
#'
#' @keywords internal
cache_set <- function(key, token, expires_at) {
  assign(
    key,
    list(token = token, expires_at = expires_at),
    envir = .ghapp_cache
  )
  invisible(token)
}

#' Clear the token cache
#'
#' Clears a specific key from the cache, or all cached tokens if no key is
#' provided.
#'
#' @param key Optional cache key in format `{app_id}_{installation_id}`. If
#'   NULL (default), clears all cached tokens.
#'
#' @return Invisibly returns NULL
#'
#' @examples
#' \dontrun{
#' # Clear a specific token
#' cache_clear("12345_67890")
#'
#' # Clear all cached tokens
#' cache_clear()
#' }
#'
#' @export
cache_clear <- function(key = NULL) {
  if (is.null(key)) {
    rm(list = ls(envir = .ghapp_cache), envir = .ghapp_cache)
  } else if (exists(key, envir = .ghapp_cache)) {
    rm(list = key, envir = .ghapp_cache)
  }
  invisible(NULL)
}
