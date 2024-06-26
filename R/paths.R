#' make a mock path
#'
#' @param path the path to look in
#' @param type what type of query is it? (e.g. `SELECT`, `INSERT`)
#' @param hash the hash of the query
#'
#' @return a constructed path to a mock
#'
#' @keywords internal
#'
#' @export
make_path <- function(path, type, hash) {
  path_out <- file.path(path, db_path_sanitize(paste0(type, "-", hash, ".R")))
  return(path_out)
}

#' Make a (short) hash from a string
#'
#' @param string the string to hash
#' @param n how long should the hash be? (default: 6)
#'
#' @return a hash for the string
#'
#' @importFrom digest digest
#'
#' @keywords internal
#'
#' @export
hash <- function(string, n = 6) {
  string <- clean_statement(string)

  return(substr(digest(as.character(string)), 1, n))
}


#' Clean a statement string
#'
#' SQL statement strings sometimes have characters and specifications that don't
#' change the meaning or are determined at query time. To avoid this, before
#' hashing a statement we clean/strip these from the statement
#'
#' @param string an SQL statement to clean
#'
#' @return the SQL statement stripped of extraneous bits
#'
#' @keywords internal
#'
#' @export
clean_statement <- function(string) {
  string <- ignore_quotes(string)
  string <- ignore_dbplyr_unique_names(string)

  return(string)
}

read_file <- function(file_path) source(file_path, keep.source = FALSE)$value

# search through db_mock_paths() to find a file, returning the first
find_file <- function(file_path) {
  for (mock_path in db_mock_paths()) {
    path_to_check <- file.path(mock_path, file_path)
    if (file.exists(path_to_check)) {
      return(path_to_check)
    }
  }

  error_msg <- glue::glue("Couldn't find the file {file_path} in any of the mock directories.")
  rlang::abort(error_msg)
}
