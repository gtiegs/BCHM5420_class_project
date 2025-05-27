#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * Run nf-core ampliseq
 */

process run_ampliseq {

    tag "nf-core/ampliseq"

    input:
    // No input needed if you already have the samplesheet and metadata

    output:
    path("results/ampliseq") into ampliseq_results

    script:
    """
    nextflow run nf-core/ampliseq \\
        -profile singularity \\
        --input_folder "./raw_fastq/" \\
        --FW_primer TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGCCTACGGGNGGCWGCAG \\
        --RV_primer GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGACTACHVGGGTATCTAATCC \\
        --metadata "./data/metadata.csv" \\
        --outdir "results/ampliseq"
    """
}