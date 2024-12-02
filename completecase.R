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



# NHANES ------------------------------------------------------------------

library("NHANES")
data(NHANES)

colnames(NHANES)

dim(NHANES)

N <- length(unique(NHANES$ID))

data <- longi_score |> 
  group_by(id) |> 
  na.omit() |> 
  janitor::clean_names()

nhanes <- NHANES |> 
  group_by(ID)

n_complete <- nhanes |>
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



# nhefs -------------------------------------------------------------------

nhefs <- read_csv("data/nhefs.csv")

N <- length(unique(nhefs$seqn))

nhefs |> 
  summarise(
    smk_intensity_82 = sum(is.na(smkintensity82_71)),
    wt_82 = sum(is.na(wt82)),
    tax_82 = sum(is.na(tax82)),
    .by = death
  )

nhefs |> 
  pivot_longer(
    cols = c(wt71, wt82), 
    names_to = "Year", 
    values_to = "Weight",
    names_prefix = "wt"
  ) |> 
  mutate(
    missing = if_else(is.na(Weight), 1, 0)
  ) |> 
  relocate(Year, Weight, missing) |> 
  ggplot(aes(x = Year, y = Weight)) +
  geom_point(aes(color = death)) +
  facet_wrap(~qsmk)


# Framingham --------------------------------------------------------------

library(riskCommunicator)
data("framingham")

framingham |> 
  summarise(
    count = n(),
    .by = PERIOD
  ) |> 
  arrange(PERIOD) |> 
  rename(Exam = PERIOD) |> 
  knitr::kable()

framingham |> 
  summarise(
    count = n(),
    .by = CURSMOKE
  )

framingham |> 
  summarise(
    count = n(),
    .by = c(CURSMOKE, CVD)
  )

framingham |> 
  ggplot(aes(x = PERIOD, y = BMI)) +
  geom_jitter(width = .15)

framingham |> 
  mutate(time_period = as.factor(PERIOD)) |> 
  ggplot(aes(y = time_period, x = BMI)) +
  ggridges::geom_density_ridges(aes(fill = time_period), alpha = .7) +
  scale_fill_viridis_d(begin = 0.5)



# Simulation data ---------------------------------------------------------

longi_sim <- read_csv("data/longi_score_sim.csv")

N <- length(unique(longi_sim$id))

sim <- longi_sim |> 
  group_by(id) |> 
  na.omit() |> 
  janitor::clean_names()

n_complete_sim <- sim |>
  filter(week %in% c(0, 16)) |> 
  summarise(
    first_and_last = n() == 2
  ) |> 
  pull(first_and_last) |> 
  sum()

complete_sim_id <- sim |>
  filter(week %in% c(0, 16)) |> 
  summarise(
    first_and_last = n() == 2
  ) |> 
  filter(first_and_last) |> 
  pull(id)

complete_sim <- longi_sim |> 
  filter(
    id %in% complete_sim_id
  ) |> 
  mutate(DID = week * treat)

write_csv(complete_sim, file = "data/complete_sim.csv")
