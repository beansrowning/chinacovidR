#' @title Scrape links to NHC COVID-19 Daily Bulletin
#' @import rvest
cn_page_link_scrape <- function(html_page, root_url = "http://en.nhc.gov.cn/") {
  partial_href <- html_page %>%
    html_elements("div.section-list") %>%
    html_elements("div.list") %>%
    html_elements("li") %>%
    html_elements("a") %>%
    html_attr("href")

  out <- sprintf("%s%s", root_url, partial_href)

  return(out)
}

#' @title Helper to convert URL to Date based on assumed format
#' Yeah yeah, I could have used str_match, but then I would have to install stringi
#' each time on CI/CD. That's a PITA.
href_to_date <- function(x) {
  char_dates <- gsub(".*(\\d{4}-\\d{2})/(\\d{2}).*", "\\1-\\2", x)
  out <- as.Date(char_dates, "%Y-%m-%d")

  return(out)
}

#' @title A simple HTML page reader with debouncer
#' This is a stupidly simple function to get around
#' rate-limit or anti-crawling measures by dynamically
#' waiting between each request for a set time.
#'
#' It's heuristic, and may still return a try-error that
#' must be handled downstream. Ideally I'd use OOP and handle
#' this at the app level instead of the request level.
#'
#' @param page_url (character) A URL we want to read
#' @param max_wait (numeric) Maximum debounce
#'
#' @note max_wait
read_page <- function(page_url, max_wait = 20) {
  debounce_n <- 2
  not_read <- TRUE

  while (debounce_n < max_wait && not_read) {
    page_read <- try(read_html(page_url), silent = TRUE)

    if (inherits(page_read, "try-error")) {
      Sys.sleep(debounce_n)
      debounce_n <- debounce_n + 2
    } else {
      not_read <- FALSE
    }
  }

  return(page_read)
}
