# ====
# Demo Script to perform full scrape
# Default is 2 parallel workers to pull content
# Sean Browning (sbrowning <a> cdc <punto> com)
library(chinacovidR)

link_frame <- pull_nhc_article_links()
full_frame <- pull_nhc_article_content(link_frame, n_workers = 2)

write.csv(full_frame, system.file("latest_nhc_data.csv", package = "chinacovidR"))