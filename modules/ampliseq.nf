#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * Run nf-core ampliseq
 */

process run_ampliseq {

    tag "nf-core/ampliseq"

    input:
    path("raw_fastq")

    output:
    path("results/ampliseq") into ampliseq_results

    script:
    """
    nextflow run nf-core/ampliseq \\
        -profile docker \\
        --input_folder "./raw_fastq/" \\
        --FW_primer '${params.FW_primer}' \\
        --RV_primer '${params.RV_primer}' \\
        --metadata "./data/metadata.csv" \\
        --outdir "results/ampliseq"
    """
}