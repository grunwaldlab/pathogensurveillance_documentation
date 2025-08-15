library(metacoder)
library(readr)

max_context_taxa <- 10

source('modified_pick_assemblies.R')

selected <- read_tsv('LF1.tsv')
all_data <- read_tsv('LF1_raw.tsv')

# Remove odd data
all_data <- all_data[all_data$genus != "Streptomycetaceae", ]
all_data <- all_data[all_data$genus != "Lactobacillaceae", ]

all_data$root <- 'All'
obj <- parse_tax_data(all_data, class_cols = c('root', 'family', 'genus', 'species', 'organism_name'))
tax_names <- taxon_names(obj)
tax_ids <- taxon_ids(obj)

selected_assem <- all_data$organism_name[!is.na(all_data$selection_rank)]
selected_assem_ids <- tax_ids[is_leaf(obj) & tax_names %in% selected_assem]
names(selected_assem_ids) <- tax_names[selected_assem_ids]
selected_for <- unique(all_data$selection_taxon[!is.na(all_data$selection_taxon)])
selected_for_ids <- tax_ids[tax_names %in% selected_for]
names(selected_for_ids) <- tax_names[selected_for_ids]

subtaxa_1_ids <- subtaxa(obj, recursive = 1, simplify = FALSE, value = 'taxon_ids')
subtaxa_1_ids <- lapply(subtaxa_1_ids, function(x) {
  names(x) <- tax_names[x]
  x
})
selected_for_sub <- subtaxa_1_ids[selected_for_ids]
selected_for_sub <- lapply(selected_for_sub, function(x) {
  x <- x[! x %in% selected_assem_ids & ! x %in% selected_for_ids]
  x[seq_len(min(length(x), max_context_taxa))]
})
selected_for_sub <- unlist(unname(selected_for_sub))

supertaxa_id <- supertaxa(obj, simplify = FALSE, value = 'taxon_ids')
selected_taxa <- unique(unlist(supertaxa_id[selected_assem_ids]))
selected_taxa <- c(selected_taxa, selected_assem_ids)
names(selected_taxa) <- tax_names[selected_taxa]

taxa_to_plot <- unique(c(selected_for_sub, selected_assem_ids, selected_for_ids))
names(taxa_to_plot) <- tax_names[taxa_to_plot]

color_labels <- function(id) {
  output <- rep('grey', length(id))
  output[id %in% selected_assem_ids] <- 'black'
  output[id %in% selected_for_ids] <- 'red'
  return(output)
}

obj %>%
  filter_taxa(taxon_ids %in% taxa_to_plot, supertaxa = TRUE) %>%
  # filter_taxa(! is_internode | taxon_names %in% selected_for) %>%
  heat_tree(
    # node_label = ifelse(taxon_ids %in% selected_assem_ids | taxon_ids %in% selected_for_ids, taxon_names, ''),
    node_label_color = color_labels(taxon_ids),
    node_size = n_obs,
    node_size_range = c(0.005, 0.035),
    node_label_size_range = c(0.01, 0.03),
    edge_color = ifelse(taxon_ids %in% selected_taxa, '#888888', 'grey'),
    node_color = color_labels(taxon_ids),
    make_node_legend = FALSE,
    make_edge_legend = FALSE,
    output_file = 'reference_selection_figure.pdf'
  )
