#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { DOWNLOAD_FASTQ } from './modules/download.nf'

workflow {
    log.info """
    ===================================================
    SRA download ( PRJNA955174 ) for nf-core/ampliseq
    ===================================================
    accessions   : ${params.accessions}
    FW_primer    : ${params.FW_primer}
    RV_primer    : ${params.RV_primer}
    metadata     : ${params.metadata}
    outdir       : ${params.outdir}
    ===================================================
    """

    // Read accessions from list and create channel
    accessions_ch = channel
        .fromPath(params.accessions)
        .splitText()
        .map { it.trim() }
        .filter { it.length() > 0 }

    // Download FASTQ files from SRA
    DOWNLOAD_FASTQ(accessions_ch)
    
    // Collect all downloaded fastq files
    downloaded_files = DOWNLOAD_FASTQ.out.fastq.collect()

    // SRA-tools prefetch and fasterq-dump is complete
    downloaded_files.view { 
        "FASTQ file download completed. Beginning to run nf-core/ampliseq with: --input ${params.outdir}/fastq --FW_primer '${params.FW_primer}' --RV_primer '${params.RV_primer}'"
    }
}