#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { DOWNLOAD_FASTQ } from './modules/download.nf'

workflow {
    log.info """
    ========================================
    16S rRNA Pipeline with Direct FASTQ Input
    ========================================
    accessions   : ${params.accessions}
    fw_primer    : ${params.FW_primer}
    rv_primer    : ${params.RV_primer}
    metadata     : ${params.metadata}
    outdir       : ${params.outdir}
    ========================================
    """

    // Read accessions from list and create channel
    accessions_ch = channel
        .fromPath(params.accessions)
        .splitText()
        .map { it.trim() }
        .filter { it.length() > 0 }

    // Download FASTQ files from SRA
    DOWNLOAD_FASTQ(accessions_ch)
    
    // Wait for all downloads to complete, then run ampliseq
    DOWNLOAD_FASTQ.out.fastq.collect().view { fastq_files ->
        
        log.info "All SRA downloads completed. Running nf-core/ampliseq..."
        
        // Run nf-core/ampliseq using --input_folder
        ampliseq_cmd = """
        nextflow run nf-core/ampliseq \\
            -profile docker \\
            --input_folder "${params.outdir}/fastq" \\
            --extension "*_{1,2}.fastq.gz" \\
            --fw_primer "${params.fw_primer}" \\
            --rv_primer "${params.rv_primer}" \\
            --metadata "${params.metadata}" \\
            --outdir ${params.ampliseq_outdir}
        """
        
        log.info "Executing: ${ampliseq_cmd}"
        
        // Execute the command
        def process = ampliseq_cmd.execute()
        process.waitFor()
        
        if (process.exitValue() == 0) {
            log.info "nf-core/ampliseq completed successfully!"
            log.info "Results are available in: ${params.ampliseq_outdir}"
        } else {
            error "nf-core/ampliseq failed with exit code: ${process.exitValue()}"
        }
        
        return "Pipeline completed successfully!"
    }
    
    emit:
    fastq_files = DOWNLOAD_FASTQ.out.fastq
}