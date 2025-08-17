# Scripts and data for assessing the performance of the `nf-core/pathogensurveillance` pipeline

This repository contains the experimental data, analysis scripts, and results that were used in benchmarking experiments that accompany the following manuscript: 

**Foster et al. (2025)**  
*Pathogensurveillance: an automated Nextflow pipeline for rapid identification, population genomic, and evolutionary analyses of pathogens.*  

**The latest release of the pipeline is here: [nf-core/pathogensurveillance pipeline](https://nf-co.re/pathogensurveillance/latest/)**

---

## Repository structure


```text
benchmark_pathogensurveillance_performance/
├── data/
│   ├── sample_size/
│   └── genome_size/
├── scripts/
│   ├── sample_size/
│   └── genome_size/
├── results/
│   ├── sample_size/
│   └── genome_size/
└── metadata/
    ├── sample_size/
    └── genome_size/
```

`data/` — Select outputs from pathogensurveillance runs  

`scripts/` — Scripts and commands used to set up experiments and to then run and analyze pipeline performance  

`results/` — Output tables parsed from pipeline outputs  

`metadata/` — Sample metadata and information on input data

---

## Performance evaluation experiments

### Genome size experiments

These experiments assess how the pipeline performs across a range of genome sizes.

* **Step 01**:  
  * Pipeline run on 14 different datasets (pathogens, plants, other microorganisms), each comprised of 3 samples

* **Step 02**: 
  * Based on initial assembly QUAST report and FASTQC output describing read length, reads were subset to approximate coverage of 25x or 50x for prokaryote or eukaryote samples, respectively.  
  * The worksheet showing these outputs is [here](metadata/genome_size/accessions_subset_info.csv).   

* **Step 03**: 
  * The subset reads were used as input data for the subsequent runs.  
  * This command was used:  
    ```bash
    nextflow run main.nf -profile docker \
      --input metadata/sample_size/${genus}_${species}_sub.csv \
      --outdir ${OUTPUT_DIR}/genome_size/${organism}_${run_num} \
      -with-report -with-trace \
      --data_dir ${pathsurv_data}/${organism}
    ```
        
* **Step 04**: 
  * Output directory is copied, and runs were deleted from the cache  

* **Step 05**: 
  * Repeat Steps 3 and 4 twice, to obtain three runs for each organism
  
* **Step 06**: 
  * Parse outputs using [parse_output_stats.Rmd](scripts/genome_size/parse_output_stats.Rmd)

### Sample size experiments

These experiments evaluate the pipeline's scalability with increasing numbers of samples.

* **Step 01**:  
  * Downloaded the PE reads fo 232 *Klebsiella pneumaniae* [accessions](https://raw.githubusercontent.com/nf-core/test-datasets/refs/heads/pathogensurveillance/samplesheets/klebsiella.csv)    

* **Step 02**: Use [run_test_data.sh](scripts/sample_size/run_test_data.sh) to first randomize and write [input CSV](metadata/sample_size/input_data.csv) file  
  * After, script sequentially runs the nextflow pipeline, on the 1, 3, 5, 10, 25, 50, 75, 100, 150, and 200 randomized accessions  
  * Script also contains step to deleted runs from cache and files are copied for later steps  
  * Within the script, the basic Nextflow command was:  
    ```bash
    nextflow run main.nf -profile docker \
      --input metadata/input_data_subset.csv \
      --outdir OUTPUT_DIR/${NUM}_${RUN} \
      --max_samples ${NUM} \
      -with-report -with-trace \
      --data_dir ${pathsurv_data}/k_pneumoniae
    ```
* **Step 03**: Step 01 and Steps 02 were repeated twice more for a total of 3 replicate runs (each using a different randomized input set)

* **Step 04**:  
  * Parse outputs using [parse_output_stats.Rmd](scripts/sample_size/parse_output_stats.Rmd)

---

## Specifications of computer used for benchmarking experiments

* **Desktop:** System76 Thelio Major (R4)  

* **OS:** Pop!_OS 22.04 LTS (with full disk encryption)  

* **CPU:** AMD Ryzen 9 7950X — 16 Cores / 32 Threads @ 5.7 GHz  

* **RAM:** 128 GB DDR5 3600 MHz (4×32)  

* **Storage:** 8 TB PCIe 4.0 NVMe M.2 SSD  

* **GPU:** NVIDIA GeForce RTX 4080 — 16 GB (*Not required*)

---
