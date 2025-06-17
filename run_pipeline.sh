#!/bin/bash

# Activate conda environment
conda activate 5420_16S_pipeline

# Run the download workflow first
echo "Starting SRA download..."
nextflow run main.nf -profile docker -resume

# Check if download was successful
if [ $? -eq 0 ]; then
    echo "SRA download completed successfully. Starting ampliseq..."
    
    # Run nf-core/ampliseq
    nextflow run ampliseq/main.nf \
        -profile docker \
        -resume \
        --input_folder ".results/fastq" \
        --extension "*_{1,2}.fastq.gz" \
        --FW_primer 'TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGCCTACGGGNGGCWGCAG' \
        --RV_primer 'GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGACTACHVGGGTATCTAATCC' \
        --metadata "./data/metadata.tsv" \
        --metadata_category "VISIT,SUBJECT" \
        --metadata_category_barplot "VISIT" \
        --outdir ".results/ampliseq" \
        --ancombc 
else
    echo "SRA download failed. Ending pipeline."
    exit 1
fi