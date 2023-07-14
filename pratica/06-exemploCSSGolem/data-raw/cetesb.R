## code to prepare `cetesb` dataset goes here

cetesb <- readRDS("data-raw/cetesb.rds")

usethis::use_data(cetesb, overwrite = TRUE)
