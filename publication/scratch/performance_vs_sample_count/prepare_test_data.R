metadata <- read.csv('https://raw.githubusercontent.com/nf-core/test-datasets/refs/heads/pathogensurveillance/samplesheets/klebsiella.csv')
metadata <- metadata[metadata$sequence_type == "ILLUMINA" & metadata$Organism == "Klebsiella pneumoniae", ]
write.csv(metadata, file = 'input_data_subset.csv', row.names = FALSE)
