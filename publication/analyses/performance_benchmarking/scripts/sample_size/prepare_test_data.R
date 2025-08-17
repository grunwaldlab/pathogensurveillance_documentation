metadata <- read.csv('https://raw.githubusercontent.com/nf-core/test-datasets/refs/heads/pathogensurveillance/samplesheets/klebsiella.csv')
metadata <- metadata[metadata$sequence_type == "ILLUMINA" & metadata$Organism == "Klebsiella pneumoniae", ]
metadata <- metadata[sample(nrow(metadata)), ]
write.csv(metadata, file = '~/pathogensurveillance_publications/publication/analyses/performance_benchmarking/metadata/input_data.csv', row.names = FALSE)
