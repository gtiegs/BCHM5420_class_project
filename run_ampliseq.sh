#!/bin/bash

# Activate conda environment
conda activate 5420_16S_pipeline

# Run nf-core/ampliseq
    nextflow run ampliseq/main.nf \
        -profile docker \
        -resume \
        --input_folder "./results/fastq/" \
        --extension "*_{1,2}.fastq.gz" \
        --FW_primer 'TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGCCTACGGGNGGCWGCAG' \
        --RV_primer 'GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGACTACHVGGGTATCTAATCC' \
        --metadata "./data/metadata2.tsv" \
        --metadata_category "VISIT,SUBJECT" \
        --metadata_category_barplot "VISIT" \
        --trunc_qmin 15 \
        --outdir ".results/ampliseq" \
        --ancombc