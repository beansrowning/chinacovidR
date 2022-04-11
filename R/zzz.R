nhcNlp <- NULL
nlp_avail <- FALSE
.onLoad <- function(libname, pkgname) {
  venv_avail <- try(reticulate::use_virtualenv(virtualenv = "chinacovidR"), silent = TRUE)
  
  if (!inherits(venv_avail, "try-error")) {

    # Install spacy english language models
    system2(reticulate::py_exe(), c("-m", "spacy", "download", "en_core_web_sm"))

    nhcNlp <<- reticulate::import_from_path(
      "nhcNlp",
      path = system.file("nhcNlp", package = "chinacovidR"),
      delay_load = TRUE
    )
    nlp_avail <<- TRUE
  } else {
    packageStartupMessage("Use install_nlp() for NLP functionality")
  }

}