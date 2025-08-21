library(PathoSurveilR)
library(ggplot2)

my_plot <- plot_tree('data/report_group_data/mixed_inputs', target = 'multigene_tree')
ggsave(my_plot$Default, width = 6, height = 20, path = 'results', filename = 'complex_dataset_tree.pdf')
