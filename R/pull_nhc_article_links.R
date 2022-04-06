# Function to pull links to China NHC Covid bulletins.
# previous_run: path to a CSV file containing data from previous run of this function
# (in which case, we will only read back as far as the latest date in those data)
#' @export 
pull_nhc_article_links <- function(root_url = "http://en.nhc.gov.cn", previous_run = NULL) {

  first_page_url <- url_absolute("DailyBriefing.html", root_url)

  # Read in page
  first_page_read <- read_page(first_page_url)

  # Pull list of links to articles
  first_page_links <- cn_page_link_scrape(first_page_read, root_url)

  # Construct date stamps from href
  first_page_dates <- href_to_date(first_page_links)

  article_df <- data.frame(
    date = first_page_dates,
    url = first_page_links,
    read_time = Sys.time(),
    content = "to be read"
  )

  if (!is.null(previous_run)) {
    prev_run_data <- read.csv(previous_run)
    prev_run_data[["date"]] <- as.Date(prev_run_data[["date"]])
    prev_run_data[["read_time"]] <- as.POSIXct(prev_run_data[["read_time"]])
    prev_latest_date <- max(prev_run_data[["date"]])
    page_latest_date <- max(first_page_dates)

    # Remove any from the first page that we already have
    # from a previous run
    to_bind <- article_df[!article_df$date %in% prev_run_data[["date"]], ]

    article_df <- rbind(
      prev_run_data,
      to_bind
    )

    article_df <- article_df[order(article_df$date, decreasing = TRUE), ]

    if (prev_latest_date <= page_latest_date) {
      return(article_df)
    }
  }

  # === Loop over each additional page
  pg_num <- 2L

  # Loop until error is thrown from page
  repeat {
    next_page_url <- url_absolute(sprintf("DailyBriefing_%d.html", pg_num), root_url)
    next_page_read <- read_page(next_page_url)

    # If we can't read the page, stop the process
    if (inherits(next_page_read, "try-error")) {
      break
    }

    # Pull list of links to articles
    next_page_links <- cn_page_link_scrape(next_page_read, root_url)

    # Construct date stamps from href
    next_page_dates <- href_to_date(next_page_links)
    page_latest_date <- max(first_page_dates)

    # Recurse over links from page
    page_df <- data.frame(
      date = next_page_dates,
      url = next_page_links,
      read_time = Sys.time(),
      content = "to be read"
    )

    if (!is.null(previous_run)) {
      # Bind existing links to links from this page

      # Remove any links from the page that we already have
      # from a previous run
      to_bind <- page_df[!page_df$date %in% article_df[["date"]], ]

      article_df <- bind_rows(
        article_df,
        to_bind
      )

      article_df <- article_df[order(article_df$date, decreasing = TRUE), ]

      # If we've reached the latest date on this page,
      # stop and return
      if (prev_latest_date <= page_latest_date) {
        return(article_df)
      }

    } else {
      # Bind existing links to links from this page
      article_df <- rbind(
        article_df,
        page_df
      )
    }

    pg_num <- pg_num + 1L
  }

  # Return what we have
  article_df <- article_df[order(article_df$date, decreasing = TRUE), ]
  return(article_df)
}
