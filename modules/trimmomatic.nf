process TRIMMOMATIC {
    tag "$sample_id"
    label 'process_medium'
    
    publishDir "${params.outdir}/trimmed_reads", mode: params.publish_dir_mode, pattern: "*.fq.gz"
    
    input:
    tuple val(sample_id), path(reads)
    
    output:
    tuple val(sample_id), path("*_paired_*.fq.gz"), emit: paired_reads
    tuple val(sample_id), path("*_unpaired_*.fq.gz"), emit: unpaired_reads, optional: true
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    def prefix = reads[0].toString().replaceAll(/\.fastq|\.fq|\.fastq\.gz|\.fq\.gz/, "")
    def trimmomatic_opts = params.trimmomatic_options ?: "ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36"
    
    """
    trimmomatic PE \\
        -threads $task.cpus \\
        -phred33 \\
        ${reads[0]} ${reads[1]} \\
        ${prefix}_paired_1.fq.gz ${prefix}_unpaired_1.fq.gz \\
        ${prefix}_paired_2.fq.gz ${prefix}_unpaired_2.fq.gz \\
        $trimmomatic_opts
    """
    
    stub:
    def prefix = reads[0].toString().replaceAll(/\.fastq|\.fq|\.fastq\.gz|\.fq\.gz/, "")
    """
    touch ${prefix}_paired_1.fq.gz
    touch ${prefix}_paired_2.fq.gz
    touch ${prefix}_unpaired_1.fq.gz
    touch ${prefix}_unpaired_2.fq.gz
    """
}
