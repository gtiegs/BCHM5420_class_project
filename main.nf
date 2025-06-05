#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { fetchngs_and_ampliseq } from './workflows/fetchngs_and_ampliseq.nf'

workflow {
    fetchngs_and_ampliseq()
}