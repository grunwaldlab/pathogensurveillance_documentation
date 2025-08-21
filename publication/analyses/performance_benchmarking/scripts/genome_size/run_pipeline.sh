#!/usr/bin/env bash
OUTPUT_DIR=data
nextflow run main.nf -profile docker --input metadata/sample_size/${Genus}_${Species}_sub.csv --outdir ${OUTPUT_DIR}/genome_size/${organism}_${run_num} -with-report -with-trace --data_dir ${pathsurv_data}/${organism}
