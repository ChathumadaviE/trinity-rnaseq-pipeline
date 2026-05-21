process MULTIQC {
    tag "MultiQC Report"
    label 'process_medium'
    
    publishDir "${params.outdir}/multiqc", mode: params.publish_dir_mode
    
    input:
    path fastqc_results
    path trinity_assembly
    path busco_results
    
    output:
    path "multiqc_report.html", emit: html
    path "multiqc_data/", emit: data
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    """
    multiqc . \\
        -n multiqc_report.html \\
        --interactive \\
        -f
    """
    
    stub:
    """
    mkdir -p multiqc_data
    touch multiqc_report.html
    """
}
