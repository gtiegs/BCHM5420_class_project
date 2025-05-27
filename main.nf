#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { download_fastq } from './modules/download.nf'
include { run_ampliseq } from './modules/ampliseq.nf'

workflow {
    accessions = Channel
        .fromPath('./data/accession_list.txt')
        .splitText()
        .filter { it.trim() }

    download_fastq(accessions)

    run_ampliseq()
}