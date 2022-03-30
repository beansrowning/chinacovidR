#' @title Scrape links to NHC COVID-19 Daily Bulletin
#' @import rvest
cn_page_link_scrape <- function(html_page, root_url = "http://en.nhc.gov.cn/") {
  partial_href <- html_page %>%
    html_elements("div.section-list") %>%
    html_elements("div.list") %>%
    html_elements("li") %>%
    html_elements("a") %>%
    html_attr("href")

  out <- url_absolute(partial_href, root_url)

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
read_page <- function(page_url, max_wait = 30) {
  debounce_n <- 2
  not_read <- TRUE

  # --- Handle User Agent spoofing
  user_agents <- c(
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:73.0) Gecko/20100101 Firefox/73.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.5 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36 Edge/16.16299",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:63.0) Gecko/20100101 Firefox/63.0"
  )

  # Randomly select a user agent for this session
  user_agent <- user_agents[runif(1, 1, length(user_agents))]

  # Change the user agent and save the old one so we can revert on close
  # old_agent <- options(HTTPUserAgent = user_agent)
  # on.exit(options(HTTPUserAgent = old_agent))
  httr::user_agent(user_agent)
  # Create connection ahead of time so we can close
  # gracefully
  # url_con <- url(page_url, "rb")
  # on.exit(close(url_con), add = TRUE)

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
