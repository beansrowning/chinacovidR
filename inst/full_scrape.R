# ====
# Demo Script to perform full scrape
# Default is 2 parallel workers to pull content
# Sean Browning (sbrowning <a> cdc <punto> com)
load_all()
library(readr)

link_frame <- pull_nhc_article_links(previous_run = "inst/latest_nhc_data.csv")
full_frame <- pull_nhc_article_content(link_frame, n_workers = 5)

write_csv(full_frame, "inst/latest_nhc_data.csv")
