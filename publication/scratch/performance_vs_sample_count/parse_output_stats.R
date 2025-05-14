library(tidyverse)
library(lubridate)
library(fs)

# Parameters 
run_results_dir_path <- 'run_results'

# Infer sample counts used from output folder names
sample_counts <- as.numeric(list.files(run_results_dir_path))

# Find all execution trace paths
run_data <- map_dfr(sample_counts, function(count) {
  pipeline_info_path <- file.path(run_results_dir_path, count, 'pipeline_info')
  out <- tibble(
    trace_path = list.files(pipeline_info_path, pattern = '^execution_trace', full.names = TRUE),
    report_path = list.files(pipeline_info_path, pattern = '^execution_report', full.names = TRUE),
    sample_count = count
  )
  out$replicate <- letters[seq_len(nrow(out))]
  return(out)
})
run_data$replicate <- as.factor(run_data$replicate)

# Parse HTML report to get total time stats
run_data$clock_hours <- map_chr(run_data$report_path, function(path) {
  sub(read_file(path), pattern = '^.+<span id="completed_fromnow"></span>duration: <strong>(.+?)</strong>.+$', replacement = '\\1')
})
run_data$clock_hours <- as.numeric(duration(toupper(run_data$clock_hours))) / 60 / 60
run_data$cpu_hours <- map_chr(run_data$report_path, function(path) {
  sub(read_file(path), pattern = '^.+<dt class="col-sm-3">CPU-Hours</dt>\n        <dd class="col-sm-9"><samp>(.+?)</samp></dd>.+$', replacement = '\\1')
})
run_data$cpu_hours <- as.numeric(run_data$cpu_hours)

# Get maximum RAM used from trace data
trace_tables <- map(run_data$trace_path, read_tsv)
standardize_to_gb <- function(x){
  as.numeric(fs_bytes(x)) / 10^9
}
run_data$max_rss_gb <- map_vec(trace_tables, function(stat_data) standardize_to_gb(max(stat_data$peak_rss)))
run_data$max_vmem_gb <- map_vec(trace_tables, function(stat_data) standardize_to_gb(max(stat_data$peak_vmem)))

