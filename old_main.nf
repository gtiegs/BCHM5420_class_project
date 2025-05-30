#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { download_fastq } from './modules/download.nf'
include { run_ampliseq } from './modules/ampliseq.nf'

workflow {
    // Read accessions from list and run SRA download
    accessions = Channel
        .fromPath('./data/accession_list.txt')
        .splitText()
        .filter { it.trim() }

    // Run SRA download
    downloaded_fastq = download_fastq(accessions)

    // Run nf-core ampliseq
    run_ampliseq(downloaded_fastq)
}