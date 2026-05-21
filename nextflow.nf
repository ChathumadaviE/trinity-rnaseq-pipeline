#!/usr/bin/env nextflow

/*
========================================================================================
   TRINITY DENOVO TRANSCRIPTOME ASSEMBLY PIPELINE
========================================================================================
   De novo transcriptome assembly using Trinity with QC, quantification, and annotation

   Usage:
   nextflow run nextflow.nf -profile docker,standard --reads '*.fastq' --outdir results/

========================================================================================
*/

nextflow.enable.dsl=2

// Import modules
include { FASTQC } from './modules/fastqc'
include { TRIMMOMATIC } from './modules/trimmomatic'
include { TRINITY } from './modules/trinity'
include { BUSCO } from './modules/busco'
include { BOWTIE2_BUILD } from './modules/bowtie2_build'
include { BOWTIE2_ALIGN } from './modules/bowtie2_align'
include { SALMON } from './modules/salmon'
include { TRANSDECODERIZE } from './modules/transdecoder'
include { ANNOTATION } from './modules/annotation'
include { MULTIQC } from './modules/multiqc'

// Print parameter summary
log.info """\
    ========================================
    TRINITY DENOVO TRANSCRIPTOME PIPELINE
    ========================================
    reads           : ${params.reads}
    outdir          : ${params.outdir}
    memory          : ${params.max_memory}
    cpus            : ${params.max_cpus}
    ========================================
    """.stripIndent()

// Validate inputs
if (!params.reads) { exit 1, "Error: --reads parameter not specified" }

// Create output directory
params.outdir = params.outdir ?: './results'

workflow {
    // Create channels
    read_ch = Channel.fromFilePairs( params.reads, checkIfExists: true )
    
    // QC - FastQC on raw reads
    FASTQC( read_ch )
    
    // Trimming - Trimmomatic
    trim_ch = TRIMMOMATIC( read_ch )
    
    // QC - FastQC on trimmed reads
    FASTQC( trim_ch )
    
    // De novo assembly - Trinity
    trinity_ch = TRINITY( trim_ch )
    
    // Quality assessment - BUSCO
    BUSCO( trinity_ch )
    
    // Build Bowtie2 index
    bowtie2_index = BOWTIE2_BUILD( trinity_ch )
    
    // Align reads to assembly
    bam_ch = BOWTIE2_ALIGN( trim_ch, bowtie2_index )
    
    // Transcript quantification - Salmon
    salmon_quant = SALMON( trinity_ch, trim_ch )
    
    // Protein prediction - TransDecoder
    transdecoder_ch = TRANSDECODERIZE( trinity_ch )
    
    // Functional annotation
    annotation_ch = ANNOTATION( transdecoder_ch )
    
    // Quality control summary
    MULTIQC( 
        FASTQC.out.collect().ifEmpty([]),
        trinity_ch,
        BUSCO.out.collect().ifEmpty([])
    )
}

workflow.onComplete {
    log.info """\n
        ========================================
        Pipeline execution summary
        ========================================
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        Success     : ${workflow.success}
        workDir     : ${workflow.workDir}
        exit status : ${workflow.exitStatus}
        ========================================
        """.stripIndent()
}

workflow.onError {
    log.error "Pipeline failed: ${workflow.errorReport}"
    System.exit(1)
}
