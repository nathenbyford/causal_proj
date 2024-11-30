## Nathen Byford
## Complete case analysis

library(tidyverse)
library(foreign)
library(gtsummary)


# Load data ---------------------------------------------------------------

# Read in patient level data
adsl <- read_csv("data/demo_real_data.csv")

# Read in longitudinal data
longi_score <- read_csv("data/longi_score_real_data.csv")

# Read in cluster result data 
cluster <- read_csv("data/cluster_real_data.csv")
cluster <- cluster[, c(2,3)]

# Merge patient level data and cluster data
adsl <- left_join(adsl, cluster, by = "id")


# Complete case data ------------------------------------------------------


N <- length(unique(longi_score$id))

data <- longi_score |> 
  group_by(id) |> 
  na.omit() |> 
  janitor::clean_names()

n_complete <- data |>
  filter(week %in% c(1, 6)) |> 
  summarise(
    first_and_last = n() == 2
  ) |> 
  pull(first_and_last) |> 
  sum()

complete_id <- data |>
  filter(week %in% c(1, 6)) |> 
  summarise(
    first_and_last = n() == 2
  ) |> 
  filter(first_and_last) |> 
  pull(id)

complete_data <- longi_score |> 
  filter(
    id %in% complete_id
  ) |> 
  mutate(DID = week * treat)

write_csv(complete_data, file = "data/complete_case.csv")

# DID ---------------------------------------------------------------------

did_reg <- lm(hama_total ~ treat + week + did, 
              data = complete_data)

summary(did_reg)

tbl_regression(did_reg)
