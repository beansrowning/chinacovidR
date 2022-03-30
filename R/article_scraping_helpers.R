#' @title Read in COVID-19 Daily Bulletin
cn_article_scrape <- function(href) {
  page <- read_page(href)

  # If we couldn't read the page, just return a character string.
  if (inherits(page, "try-error")) {
    return("ERROR-DID NOT READ")
  }

  article_content <- page %>%
    html_elements("div.art") %>%
    html_elements("div.art-text") %>%
    html_text2()

  return(article_content)
}

#' @title Conditionally read COVID-19 Daily Bulletin
#' Used by clusterMap and other functions to read in
#' only those articles that haven't been read in yet.
cn_conditional_article_scrape <- function(href, content) {
  to_read <- content %in% c("ERROR-DID NOT READ", "to be read")

  if (!to_read) {
    return(content)
  }

  out <- cn_article_scrape(href)

  return(out)
}
