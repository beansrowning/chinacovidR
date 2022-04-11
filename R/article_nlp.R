#' @import reticulate
extract_case_counts <- function(article_text) {
  if (!nlp_avail) {
    stop("NLP not available without Python")
  }

  out <- nhcNlp$extract_case_counts(article_text)

  return(out)
}