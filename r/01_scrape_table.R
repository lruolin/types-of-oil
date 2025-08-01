# Vegetable Oil dataset

## Scrape data from journal

## Created on 31 July 2025

# LOAD PACKAGES -----

remotes::install_github("ropensci/tabulizer")
library(tabulapdf)
library(here)
library(tidyverse)

# EXTRACT TABLE ------
file_path <-
  here(
    "journal",
    "veg_oil.pdf"
  )

tables <-
  extract_tables(
    file_path,
    pages = 3:5,
    guess = TRUE
  )

tables

dfs <- map(tables, ~ as_tibble(.x))
glimpse(dfs)

## Clean data -------

# Classes are enumerated as:
# pumpkin (1), sunflower (2),
# peanut (3), olive (4), soybean (5),
# rapeseed (6), corn (7), mixed or
# unknown type (0) of oil.

oil_df <-
  bind_rows(dfs) %>%
  select(-2, -value) %>%
  separate_wider_delim(
    1,
    delim = " ",
    names = c("id", "class")
  ) %>%
  mutate(class_chr = case_when(
    class == 1 ~ "pumpkin",
    class == 2 ~ "sunflower",
    class == 3 ~ "peanut",
    class == 4 ~ "olive",
    class == 5 ~ "soybean",
    class == 6 ~ "rapeseed",
    class == 7 ~ "corn",
    .default = "mixed_unknown" # 0
  ), .after = "class") %>%
  mutate(across(starts_with("class"), factor)) %>%
  drop_na() %>%  # should have 132 samples

  # handle <0.1 cases for Eicosanoic and eicosenoic acids
  mutate(across(starts_with("Eic"), ~case_when(
    str_detect(.x, "^<") ~ 0.5 * as.numeric(str_remove(.x, "<")),
    .default = as.numeric(.x)
  ))) %>%
  janitor::clean_names() %>%
  select(-class) %>%
  rename(class = class_chr) %>%
  mutate(id = as.integer(id))


glimpse(oil_df)

oil_df %>%
  count(class)

# EXTRACT INFO FOR UNKNOWNS -----

table_unknowns <-
  extract_tables(
    file_path,
    pages = 11,
    guess = TRUE
  )

df_unknowns <- table_unknowns[[1]] # there are 37?

names(df_unknowns) <- c(
  "description",
  "no",
  "id",
  "pumpkin",
  "sunflower",
  "peanut",
  "olive",
  "soybean",
  "rapeseed",
  "corn"
)

## Check for number of samples to tally with journal -----
glimpse(df_unknowns)

n36 <-
  oil_df %>%
  filter(class == "mixed_unknown")

anti_join(df_unknowns, n36, by = "id")
  # id = 27 = sunflower in main table
  # but unknown table included id = 27 as unknown (vegetable oil)

oil_df %>%
  filter(id == 27)

# 96 are not mixed_unknown, but journal cited as 95
oil_df %>%
  filter(class != "mixed_unknown")

oil_df %>%
  filter(class != "mixed_unknown") %>%
  filter(id != 27) # this will give 95 samples

# MERGE TABLES  -----
oil_df_with_description <-
  oil_df %>%
  left_join(df_unknowns %>%  select(id, description), by = "id") %>%
  mutate(description = case_when(
    is.na(description) ~ class,
    .default = description
  )) %>%
  mutate(description = str_to_lower(description)) %>%
  mutate(class = case_when(
    id == 27 ~ "mixed_unknown",
    .default = class
  ))

glimpse(oil_df_with_description)

oil_df_with_description %>%
  filter(id == 27)

# EXPORT ------
out_path <-
  here("data", "veg_oil_gc_conc.csv")

write_csv(oil_df_with_description, out_path)
