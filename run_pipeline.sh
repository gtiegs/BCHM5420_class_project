#!/bin/bash

# Activate conda environment
conda activate <env_name>

# Run the download workflow first
echo "Starting SRA download..."
nextflow run main.nf -profile docker

# Check if download was successful
if [ $? -eq 0 ]; then
    echo "SRA download completed successfully. Starting ampliseq..."
    
    # Run nf-core/ampliseq
    nextflow run nf-core/ampliseq \
        -profile docker \
        --input results/fastq \
        --FW_primer 'TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGCCTACGGGNGGCWGCAG' \
        --RV_primer 'GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGACTACHVGGGTATCTAATCC' \
        --metadata ./data/metadata.csv \
        --outdir results/ampliseq
else
    echo "SRA download failed. Aborting pipeline."
    exit 1
fi