library(readr)
library(ggplot2)
library(tidyr)
library(dplyr)


# Reads previously parsed data on performance
genome_size_data <- read_csv('results/genome_size/performance_stats_genome_size.csv')
sample_size_data <- read_csv('results/sample_size/performance_stats_sample_size.csv')
genome_size_metadata <- read_csv('metadata/genome_size/accessions_subset_info.csv')

# Add organisms type column
genome_size_data$organism_type <- genome_size_metadata$domain[match(genome_size_data$organism, genome_size_metadata$organism)]
sample_size_data$organism_type <- 'prokaryote'

# Add value columns for y axis
genome_size_data$value <- genome_size_metadata$ncbi_genome_estimate[match(genome_size_data$organism, genome_size_metadata$organism)]
colnames(sample_size_data)[1] <- 'value'

# Make replicate format
colnames(genome_size_data)[2] <- 'replicate'
genome_size_data$replicate <- letters[genome_size_data$replicate]

# Combine into a single table
genome_size_data$factor <- 'Genome size'
sample_size_data$factor <- 'Sample size'
needed_cols <- c(
  'value', 
  'replicate',
  'clock_hours',
  'max_rss_gb',
  'organism_type',
  'factor'
)
combined_data <- rbind(sample_size_data[, needed_cols], genome_size_data[, needed_cols])

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
ggplot(combined_data_long, aes(x = value, y = measurement, color = organism_type)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, formula = y ~ x) +
  facet_grid(rows = vars(metric), cols = vars(factor), scales = "free") +
  scale_color_manual(values = c("eukaryote" = "#1f78b4", "prokaryote" = "#33a02c")) +
  labs(
    x = NULL,
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
