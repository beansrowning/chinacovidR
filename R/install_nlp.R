install_nlp <- function() {
  stopifnot(reticulate::py_available())

  if (reticulate::virtualenv_exists("chinacovidR")) {
    warning("Package already installed, no effect!")
    return(invisible(1))
  }

  # Install deps into a virtualenv
  reticulate::virtualenv_create(
    envname = "chinacovidR",
    packages = c("numpy", "pandas", "spacy")
  )

  message("Please restart your R session!")
}