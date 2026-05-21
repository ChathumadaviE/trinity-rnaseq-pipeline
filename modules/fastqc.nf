process FASTQC {
    tag "$sample_id"
    label 'process_medium'
    
    publishDir "${params.outdir}/fastqc", mode: params.publish_dir_mode, pattern: "*.{html,zip}"
    
    input:
    tuple val(sample_id), path(reads)
    
    output:
    path "*.html", emit: html
    path "*.zip", emit: zip
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    """
    fastqc --threads $task.cpus $reads
    """
    
    stub:
    """
    touch ${reads[0]}.fastqc.html
    touch ${reads[0]}.fastqc.zip
    """
}
