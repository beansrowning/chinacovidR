% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pull_nhc_article_content.R
\name{pull_nhc_article_content}
\alias{pull_nhc_article_content}
\title{Pull all NHC COVID-19 Daily Bulletins
This recurses over a dataframe that contains links to Daily Bulletins
and reads them in (optionally in parallel). It also ignores any that have already been read in previously.}
\usage{
pull_nhc_article_content(article_links_df, n_workers = 0L)
}
\description{
Pull all NHC COVID-19 Daily Bulletins
This recurses over a dataframe that contains links to Daily Bulletins
and reads them in (optionally in parallel). It also ignores any that have already been read in previously.
}
