#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * Download fastq files from sra
 */

process DOWNLOAD_FASTQ {
    
    container "quay.io/biocontainers/sra-tools:3.2.1--h4304569_0"
    
    tag "$accession"

    publishDir "${params.outdir}/fastq", mode: 'copy'

    input:
    val accession

    output:
    tuple val(accession), path("${accession}*.fastq.gz"), emit fastq

    script:
    """
    # Create temp directory for SRA files
    mkdir -p ./sra_temp

    # Download SRA files
    prefetch $accession --output-directory ./sra_temp

    # Convert SRA files to fastq
    fasterq-dump ./sra_temp/${accession}/${accession}.sra \\
        --outdir . \\
        --split-files \\
        --threads ${task.cpus}
    
    # Compress FASTQ files
    gzip *.fastq

    # Remove temp directory
    rm -rf ./sra_temp
    """
}
