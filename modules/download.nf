#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * Download fastq files from sra
 */

process download_fastq {
    tag "$accession"

    input:
    val accession from accessions

    output:
    path("${accession}*") into fastq_files

    conda:
    "envs/sra.yaml"

    script:
    """
    prefetch $accession
    fasterq-dump $accession -O . --split-files --threads 4
    """
}
