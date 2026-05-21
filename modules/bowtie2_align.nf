process BOWTIE2_ALIGN {
    tag "$sample_id"
    label 'process_high'
    
    publishDir "${params.outdir}/bam_files", mode: params.publish_dir_mode, pattern: "*.bam*"
    
    input:
    tuple val(sample_id), path(reads)
    path(bowtie2_index)
    
    output:
    tuple val(sample_id), path("*.bam"), emit: bam
    path "*.bam.bai", emit: bai
    path "*.stats", emit: stats
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    def index_prefix = bowtie2_index[0].toString().replaceAll(/\.\d\.bt2$|\.rev\.\d\.bt2$/, "")
    def left_reads = reads[0]
    def right_reads = reads[1]
    
    """
    bowtie2 \\
        -p $task.cpus \\
        --local \\
        --no-unal \\
        -x $index_prefix \\
        -1 $left_reads \\
        -2 $right_reads \\
        | samtools view -bS - \\
        | samtools sort -@ $task.cpus -o ${sample_id}.bam -
    
    samtools index ${sample_id}.bam
    samtools stats ${sample_id}.bam > ${sample_id}.stats
    """
    
    stub:
    """
    touch ${sample_id}.bam
    touch ${sample_id}.bam.bai
    touch ${sample_id}.stats
    """
}
