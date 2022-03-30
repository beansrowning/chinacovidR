
#' @title Pull all NHC COVID-19 Daily Bulletins
#' This recurses over a dataframe that contains links to Daily Bulletins
#' and reads them in (optionally in parallel). It also ignores any that have already been read in previously.
#' @import parallel
#' @export
pull_nhc_article_content <- function(article_links_df, n_workers = 0L) {
  # If we supply > 0 workers, spin up cluster
  if (n_workers > 0L) {
    cl <- parallel::makeCluster(n_workers)
    on.exit(parallel::stopCluster(cl))

    article_content <- clusterMap(cl,
                                  cn_conditional_article_scrape,
                                  href = article_links_df[["url"]],
                                  content = article_links_df[["content"]],
                                  .scheduling = "dynamic"
                      )

  } else {
    article_content <- Map(
      cn_conditional_article_scrape,
      href = article_links_df[["url"]],
      content = article_links_df[["content"]]
    )
  }

  # Bind back in content
  out <- article_links_df
  out[["content"]] <- unlist(article_content[out[["url"]]])
  out[["content"]] <- trimws(out[["content"]], "both")

  return(out)
}
