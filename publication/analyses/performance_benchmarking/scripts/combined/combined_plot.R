library(readr)

# Reads previously parsed data on performance
genome_size_data <- read_csv('results/genome_size/performance_stats_genome_size.csv')
sample_size_data <- read_csv('results/sample_size/performance_stats_sample_size.csv')

# Make same format
colnames(genome_size_data)[2] <- 'replicate'
genome_size_data$replicate <- letters[genome_size_data$replicate]
colnames(genome_size_data)[1] <- 'value'
colnames(sample_size_data)[1] <- 'value'
genome_size_data$factor <- 'Genome size'
sample_size_data$factor <- 'Sample size'
stopifnot(all(colnames(sample_size_data) == colnames(genome_size_data)))
combined_data <- rbind(sample_size_data, genome_size_data)

# Plot
