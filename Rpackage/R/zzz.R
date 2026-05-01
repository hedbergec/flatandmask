jsoncsvmaskr_repo_url <- function() {
  "https://github.com/hedbergec/flatandmask"
}

jsoncsvmaskr_author_name <- function() {
  "Eric Hedberg"
}

jsoncsvmaskr_author_email <- function() {
  "hedbergec@outlook.com"
}

jsoncsvmaskr_disclaimer_message <- function() {
  sprintf(
    "NO WARRANTY: This tool is provided as-is, without warranty of any kind. Check the Git repo for updates and source: %s. Contact: %s <%s>.",
    jsoncsvmaskr_repo_url(),
    jsoncsvmaskr_author_name(),
    jsoncsvmaskr_author_email()
  )
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(jsoncsvmaskr_disclaimer_message())
}
