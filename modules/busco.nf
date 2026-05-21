process BUSCO {
    tag "BUSCO Assessment"
    label 'process_high'
    
    publishDir "${params.outdir}/busco", mode: params.publish_dir_mode
    
    input:
    path assembly
    
    output:
    path "busco_results/", emit: results
    path "busco_results/short_summary.*.txt", emit: summary
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    def lineage = params.busco_lineage ?: 'eukarya'
    
    """
    busco \\
        -i $assembly \\
        -l ${lineage}_odb10 \\
        -o busco_results \\
        -m transcriptome \\
        --cpu $task.cpus \\
        --force \\
        -r
    """
    
    stub:
    """
    mkdir -p busco_results
    echo "BUSCO assessment results" > busco_results/short_summary.txt
    """
}
