#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * Download fastq files from sra
 */

process download_fastq {
    
    container "quay.io/biocontainers/sra-tools:3.2.1--h4304569_0"
    
    tag "$accession"

    input:
    val accession from accessions

    output:
    path("${accession}*") into raw_fastq

    script:
    """
    mkdir -p ./raw_fastq
    prefetch $accession
    fasterq-dump $accession -O ./raw_fastq --split-files
    """
}
