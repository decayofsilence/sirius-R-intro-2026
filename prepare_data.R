library(tidyverse)

dir.create("data/source", recursive = TRUE, showWarnings = FALSE)

source_url <- "https://bioconnector.github.io/workshops/data/"
source_files <- c(
  "airway_scaledcounts.csv",
  "airway_metadata.csv",
  "annotables_grch38.csv"
)

for (file in source_files) {
  path <- file.path("data/source", file)
  if (!file.exists(path)) {
    download.file(paste0(source_url, file), path, mode = "wb")
  }
}

set.seed(42)

measurements <- read_csv(
  "data/source/airway_scaledcounts.csv",
  show_col_types = FALSE
) %>%
  arrange(ensgene) %>%
  slice_sample(n = 1000) %>%
  arrange(ensgene)

samples <- read_csv(
  "data/source/airway_metadata.csv",
  show_col_types = FALSE
) %>%
  rename(sample_id = id)

genes <- read_csv(
  "data/source/annotables_grch38.csv",
  col_types = cols(.default = col_character())
) %>%
  select(ensgene, symbol, chr, biotype) %>%
  distinct() %>%
  semi_join(measurements, by = "ensgene") %>%
  arrange(ensgene)

write_csv(measurements, "data/airway_measurements.csv")
write_csv(samples, "data/airway_samples.csv")
write_csv(genes, "data/airway_genes.csv")
