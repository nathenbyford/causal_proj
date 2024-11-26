## Nathen Byford
## Clinical trial EDA

library(tidyverse)

data <- read_csv("data/demo_real_data.csv")


# Data prep ---------------------------------------------------------------

# Read in patient level data
adsl <- read_csv("data/demo_real_data.csv")

# Read in longitudinal data
longi_score <- read_csv("data/longi_score_real_data.csv")

# Read in cluster result data 
cluster <- read_csv("data/cluster_real_data.csv")
cluster <- cluster[, c(2,3)]

# Merge patient level data and cluster data
adsl <- left_join(adsl, cluster, by = "id")



# Plots -------------------------------------------------------------------

longi_score |> 
  ggplot(aes(x = week, y = score)) +
  geom_jitter(width = .15) +
  # geom_line() +
  facet_wrap(~treat) +
  theme(legend.position = "none")


longi_score |> 
  ggplot(aes(x = week, y = score)) +
  geom_jitter(width = .15) +
  geom_smooth() +
  facet_wrap(~treat) +
  theme(legend.position = "none")

longi_score |> 
  ggplot(aes(x = week, y = score, group = week)) +
  # geom_jitter(width = .15) +
  # geom_violin(aes(fill = week)) +
  geom_boxplot(aes(fill = as.factor(week)), width = .2) +
  facet_wrap(~treat) +
  theme(legend.position = "none")


na_tab <- longi_score |> 
  summarise(
    missing = sum(is.na(score)),
    .by = week
  )

na_tab |> 
  ggplot(aes(x = week, y = missing)) +
  geom_col()
