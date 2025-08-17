#!/usr/bin/env bash
# Define parameters
SAMPLE_COUNTS=(1 3 5 10 25 50 75 100 150 200)
OUTPUT_DIR=data
COPY_DIR=data/copied
RUN=run1
# Create input data (randomizes samples used each time)
Rscript scripts/sample_size/prepare_test_data.R

# Run pipeline for each sample count
for NUM in "${SAMPLE_COUNTS[@]}"; do
    echo "=================================================================================================="
    echo "Running ${NUM} samples and saving output to ${OUTPUT_DIR}/${NUM}_${RUN}"
    echo "=================================================================================================="
    echo ""
    echo ""
    nextflow run main.nf -profile docker --input metadata/input_data.csv --outdir OUTPUT_DIR/${NUM}_${RUN} --max_samples ${NUM} -with-report -with-trace --data_dir ${pathsurv_data}/k_pneumoniae
    echo "=================================================================================================="
    echo "Run complete and saved to ${OUTPUT_DIR}/${NUM}_${RUN}"
    echo "=================================================================================================="
    echo ""
    echo ""
    cp -L -R ${OUTPUT_DIR}/${NUM}_${RUN} ${COPY_DIR}/${NUM}_${RUN}
    echo "=================================================================================================="
    echo "Directory ${OUTPUT_DIR}/${NUM}_${RUN} is copied"
    echo "=================================================================================================="
    echo ""
    echo ""
    rm -rf work
    echo "=================================================================================================="
    echo "Work directories are removed"
    echo "=================================================================================================="
    echo ""
    echo ""
done
