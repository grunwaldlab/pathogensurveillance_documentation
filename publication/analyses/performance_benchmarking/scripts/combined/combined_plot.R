library(readr)

# Reads previously parsed data on performance
genome_size_data <- read_csv('results/genome_size/performance_stats_genome_size.csv')
sample_size_data <- read_csv('results/sample_size/performance_stats_sample_size.csv')

# Add organisms type column
organism_type <- c(
  a_thaliana = "eukaryote",
  b_japonicum = "prokaryote",
  c_elegans = "eukaryote", 
  c_sativus = "eukaryote",
  f_oxysporum = "eukaryote",
  l_fermentum = "prokaryote",
  o_tauri = "eukaryote",
  p_aeruginosa = "prokaryote",
  p_capsici = "eukaryote",
  p_ramorum = "eukaryote",
  p_vivax = "eukaryote",
  s_olivochromogenes = "prokaryote",
  u_maydis = "eukaryote",
  x_hortorum = "prokaryote"
)
genome_size_data$organism <- organism_type[genome_size_data$value]
sample_size_data$organism <- 'prokaryote'

# Make same format
colnames(genome_size_data)[2] <- 'replicate'
genome_size_data$replicate <- letters[genome_size_data$replicate]
colnames(genome_size_data)[1] <- 'value'
colnames(sample_size_data)[1] <- 'value'
genome_size_data$factor <- 'Genome size'
sample_size_data$factor <- 'Sample size'
stopifnot(all(colnames(sample_size_data) == colnames(genome_size_data)))
combined_data <- rbind(sample_size_data, genome_size_data)

library(ggplot2)
library(tidyr)

# Reshape data for faceting
combined_data_long <- combined_data %>%
  pivot_longer(
    cols = c(max_rss_gb, clock_hours),
    names_to = "metric",
    values_to = "measurement"
  ) %>%
  mutate(
    metric = factor(metric,
                    levels = c("clock_hours", "max_rss_gb"),
                    labels = c("Run time (hours)", "Max RAM (GB)")),
    factor = factor(factor, levels = c("Genome size", "Sample size"))
  )

# Create the faceted plot
ggplot(combined_data_long, aes(x = value, y = measurement, color = organism)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, formula = y ~ x) +
  facet_grid(rows = vars(metric), cols = vars(factor), scales = "free") +
  scale_color_manual(values = c("eukaryote" = "#1f78b4", "prokaryote" = "#33a02c")) +
  labs(
    x = "Factor Value",
    y = NULL,
    color = "Organism",
    title = "Performance Metrics by Genome and Sample Size"
  ) +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    strip.background = element_blank(),
    strip.text = element_text(face = "bold")
  )
