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

# Make 4 panel dotplot with regression lines using ggplot facets with rows for max_rss_gb (labled "Max RAM") and clock_hours (Labeled "Run time") and columns for genome size and sample size. Color dots and regressions lines by organism (labeled "Organism") AI!
