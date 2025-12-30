#' Known GitHub App permissions
#'
#' A character vector of all valid GitHub App permission names.
#' These are used for validation when requesting scoped installation tokens.
#'
#' @keywords internal
GITHUB_PERMISSIONS <- c(
  # Repository permissions
  "actions",
  "administration",
  "checks",
  "contents",
  "deployments",
  "environments",
  "issues",
  "metadata",
  "packages",
  "pages",
  "pull_requests",
  "repository_hooks",
  "repository_projects",
  "secret_scanning_alerts",
  "secrets",
  "security_events",
  "single_file",
  "statuses",
  "vulnerability_alerts",
  "workflows",
  # Organization permissions
  "members",
  "organization_administration",
  "organization_hooks",
  "organization_plan",
  "organization_projects",
  "organization_secrets",
  "organization_self_hosted_runners",
  "organization_user_blocking",
  "team_discussions"
)

#' Validate GitHub App permissions
#'
#' Checks that a named list of permissions contains only valid permission names
#' and valid access levels.
#'
#' @param permissions A named list where names are permission names and values
#'   are access levels ("read" or "write").
#'
#' @return Invisibly returns TRUE if valid. Aborts with an error if invalid.
#'
#' @examples
#' \dontrun{
#' validate_permissions(list(contents = "read", issues = "write"))
#' }
#'
#' @keywords internal
validate_permissions <- function(permissions) {
  if (is.null(permissions)) {
    return(invisible(TRUE))
  }

  if (!is.list(permissions) || is.null(names(permissions))) {
    cli::cli_abort(c(
      "{.arg permissions} must be a named list.",
      "i" = "Example: {.code list(contents = \"read\", issues = \"write\")}"
    ))
  }

  # Check for unknown permission names
  unknown_perms <- setdiff(names(permissions), GITHUB_PERMISSIONS)
  if (length(unknown_perms) > 0) {
    cli::cli_abort(c(
      "Unknown permission{?s}: {.val {unknown_perms}}.",
      "i" = "Valid permissions are: {.val {GITHUB_PERMISSIONS}}"
    ))
  }

  # Check for valid access levels
  valid_levels <- c("read", "write")
  invalid_levels <- vapply(permissions, function(x) !x %in% valid_levels, logical(1))
  if (any(invalid_levels)) {
    bad_perms <- names(permissions)[invalid_levels]
    cli::cli_abort(c(
      "Invalid access level for permission{?s}: {.val {bad_perms}}.",
      "i" = "Access level must be {.val read} or {.val write}."
    ))
  }

  invisible(TRUE)
}
