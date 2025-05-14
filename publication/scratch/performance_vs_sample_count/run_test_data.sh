#!/usr/bin/env bash

# Define parameters
SAMPLE_COUNTS=(1 3 5 10 25 50 75 100 150 200)
OUTPUT_DIR='run_results'

# Run pipeline for each sample count
for NUM in "${SAMPLE_COUNTS[@]}"; do
    echo "=================================================================================================="
    echo "Running ${NUM} samples and saving output to ${OUTPUT_DIR}/${NUM}"
    echo "=================================================================================================="
    echo ""
    echo ""
    nextflow run nf-core/pathogensurveillance -r dev -latest -profile docker --input input_data_subset.csv --outdir ${OUTPUT_DIR}/${NUM} --max_samples ${NUM}
done