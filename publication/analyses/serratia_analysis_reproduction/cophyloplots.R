library(ape)
library(ggtree)
library(ggplot2)
library(dplyr)
library(tidytree)

setwd("/co-phylogeny")

# Read trees
t1 <- read.tree("ps_files/serratia/validation_serratia_cluster_1.treefile")
t2 <- read.tree("ref_files/snp_sites_aln_panaroo.aln.treefile")

# fix underscores vs. dots if needed
t1$tip.label <- sub("^(GCA_[0-9]+)_1_", "\\1.1_", t1$tip.label)

# drop missing tips
common.tips <- intersect(t1$tip.label, t2$tip.label)
t1 <- drop.tip(t1, setdiff(t1$tip.label, common.tips))
t2 <- drop.tip(t2, setdiff(t2$tip.label, common.tips))

# Root at midpoint
t1 <- phangorn::midpoint(t1)
t2 <- phangorn::midpoint(t2)

# Read metadata
md <- read.delim("ps_files/serratia/sample_data.tsv", sep="\t", header=TRUE, stringsAsFactors=FALSE)

# For each tip in the common set, the same label is in both t1 and t2
assoc <- cbind(common.tips, common.tips)
colnames(assoc) <- c("t1_tip", "t2_tip")

# mapping species to hex color
species_colors <- c(
  "Serratia marcescens"       = "#73A057",
  "Serratia plymuthica"       = "#E3C854",
  "Serratia entomophila"      = "#5D78A4",
  "Serratia quinivorans"      = "#B6AEA9",
  "Serratia rubidaea"         = "#E79CA6",
  "Serratia liquefaciens"     = "#8CB6AE",
  "Serratia proteamaculans"   = "#A37B9E",
  "Serratia ficaria"          = "#DA8D38",
  "Serratia fonticola"        = "#C55759",
  "Serratia grimesii"         = "#917461",
  "Serratia rubidaea-'like'"  = "#9F9F9F",
  "Serratia odorifera"        = "#CDB3A6"
)

lineage_colors <- c(
  "1"       = "#73A057",
  "2"       = "#E3C854",
  "4"       = "#5D78A4",
  "5"       = "#B6AEA9",
  "6"       = "#E79CA6",
  "7"       = "#8CB6AE",
  "9"       = "#A37B9E",
  "12"      = "#DA8D38",
  "13"      = "#C55759",
  "14"      = "#917461",
  "15"      = "#1D283B",
  "22"      = "#CDB3A6"
)


# Build a named vector mapping each tip label -> species
tip2species <- setNames(md$fastani_derived_species, md$name)
tip2lineage <- setNames(md$lineage, md$name)

# For each row of assoc, find the species of the t1_tip
species_of_assoc <- tip2species[ assoc[, "t1_tip"] ]
lineage_of_assoc <- as.character(tip2lineage[ assoc[, "t1_tip"] ])
# Now map that species to a color
link_cols <- species_colors[ species_of_assoc ]
link_cols <- lineage_colors[ lineage_of_assoc ]

# For t1
tip_col_t1 <- species_colors[ tip2species[t1$tip.label] ]
names(tip_col_t1) <- t1$tip.label

tip_col_t1 <- lineage_colors[ tip2lineage[t1$tip.label] ]
names(tip_col_t1) <- t1$tip.label

# For t2
tip_col_t2 <- species_colors[ tip2species[t2$tip.label] ]
names(tip_col_t2) <- t2$tip.label

tip_col_t2 <- lineage_colors[ tip2lineage[t2$tip.label] ]
names(tip_col_t2) <- t2$tip.label

my_cophylo <- cophylo(
  t1, t2,
  assoc     = assoc,
  rotate    = TRUE  # automatically rotate nodes to reduce crossing
)

pdf("species_core_gene_cophylo.pdf", width = 7, height = 11)
plot(
  my_cophylo,
  link.type = "straight",     # or "straight"
  link.lwd  = 1,            # thickness of lines
  link.col  = link_cols,    # color vector we built above
  tip.color = list(tip_col_t1, tip_col_t2),  # color each tip label
  fsize     = c(0.2, 0.2),  # tip label font size for left & right trees
  link.lty="solid"
)
dev.off()

pdf("lineage_core_gene_cophylo.pdf", width = 7, height = 11)
plot(
  my_cophylo,
  link.type = "straight",     # or "straight"
  link.lwd  = 1,            # thickness of lines
  link.col  = link_cols,    # color vector we built above
  tip.color = list(tip_col_t1, tip_col_t2),  # color each tip label
  fsize     = c(0.2, 0.2),  # tip label font size for left & right trees
  link.lty="solid"
)
dev.off()


##############################################################################
# 4) Extract final tip layout from last_plot.cophylo
##############################################################################
obj <- get("last_plot.cophylo", envir = .PlotPhyloEnv)

# Left tree
left_nTips      <- obj$left$Ntip
left_tips_index <- seq_len(left_nTips)           # indices for tips
left_tip_labels <- my_cophylo$trees[[1]]$tip.label  # rearranged after cophylo
left_tip_x      <- obj$left$xx[left_tips_index]
left_tip_y      <- obj$left$yy[left_tips_index]

left_tips_df <- data.frame(
  label   = left_tip_labels,
  x       = left_tip_x,
  y       = left_tip_y,
  lineage = tip2lineage[left_tip_labels]  # attach lineage info
)
left_tips_df <- data.frame(
  label   = left_tip_labels,
  x       = left_tip_x,
  y       = left_tip_y,
  species = tip2species[left_tip_labels]  # attach lineage info
)

# Right tree
right_nTips      <- obj$right$Ntip
right_tips_index <- seq_len(right_nTips)
right_tip_labels <- my_cophylo$trees[[2]]$tip.label
right_tip_x      <- obj$right$xx[right_tips_index]
right_tip_y      <- obj$right$yy[right_tips_index]

right_tips_df <- data.frame(
  label   = right_tip_labels,
  x       = right_tip_x,
  y       = right_tip_y,
  lineage = tip2lineage[right_tip_labels]
)
right_tips_df <- data.frame(
  label   = right_tip_labels,
  x       = right_tip_x,
  y       = right_tip_y,
  species = tip2species[right_tip_labels]
)

##############################################################################
# 5) Derive the top-to-bottom order of lineages from the left tree
##############################################################################
# Sort left_tips_df by descending y
left_tips_ordered <- left_tips_df %>%
  arrange(desc(y))

# Extract lineages in top-to-bottom order
lineage_order <- unique(left_tips_ordered$lineage)
species_order <- unique(left_tips_ordered$species)

print(lineage_order)
print(species_order)

##############################################################################
# 6) Summarize lineages for stacked bars
##############################################################################
left_summary <- left_tips_df %>%
  group_by(lineage) %>%
  summarize(count = n()) %>%
  mutate(tree = "Tree 1")

left_summary <- left_tips_df %>%
  group_by(species) %>%
  summarize(count = n()) %>%
  mutate(tree = "Tree 1")

right_summary <- right_tips_df %>%
  group_by(lineage) %>%
  summarize(count = n()) %>%
  mutate(tree = "Tree 2")

right_summary <- right_tips_df %>%
  group_by(species) %>%
  summarize(count = n()) %>%
  mutate(tree = "Tree 2")

combined_summary <- bind_rows(left_summary, right_summary)

# Convert lineage to a factor with that top-to-bottom order
combined_summary$lineage <- factor(
  combined_summary$lineage,
  levels = lineage_order
)

combined_summary$species <- factor(
  combined_summary$species,
  levels = species_order
)

##############################################################################
# 7) Plot stacked bar chart with same top-to-bottom order
##############################################################################
sb <- ggplot(combined_summary, aes(x = tree, y = count, fill = lineage)) +
  geom_bar(
    stat = "identity",
    position = position_stack(reverse = FALSE)  # so first factor level is top
  ) +
  scale_fill_manual(values = lineage_colors, na.value="gray") +
  labs(
    x = "Tree",
    y = "Number of Tips",
    title = "Tip Composition by Lineage (Ordered as in Cophylo)"
  ) +
  theme_minimal()

ggsave("lineage_stack_bars.pdf", plot = sb, width = 3, height = 11, units = "in", dpi = 300, device = "pdf")


sb <- ggplot(combined_summary, aes(x = tree, y = count, fill = species)) +
  geom_bar(
    stat = "identity",
    position = position_stack(reverse = FALSE)  # so first factor level is top
  ) +
  scale_fill_manual(values = species_colors, na.value="gray") +
  labs(
    x = "Tree",
    y = "Number of Tips",
    title = "Tip Composition by Species (Ordered as in Cophylo)"
  ) +
  theme_minimal()

ggsave("species_stack_bars.pdf", plot = sb, width = 3, height = 11, units = "in", dpi = 300, device = "pdf")
