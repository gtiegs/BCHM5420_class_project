#!/bin/bash

# Activate conda environment
conda activate 5420_16S_pipeline

# Run the download workflow first
echo "Starting SRA download..."
nextflow run main.nf -profile docker

# Check if download was successful
if [ $? -eq 0 ]; then
    echo "SRA download completed successfully. Starting ampliseq..."
    
    # Run nf-core/ampliseq
    nextflow run ampliseq/main.nf \
        -profile docker \
        --input results/fastq \
        --extension "*_{1,2}.fastq.gz" \
        --FW_primer 'TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGCCTACGGGNGGCWGCAG' \
        --RV_primer 'GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGACTACHVGGGTATCTAATCC' \
        --metadata ./data/metadata.tsv \
        --outdir results/ampliseq
else
    echo "SRA download failed. Ending pipeline."
    exit 1
fi