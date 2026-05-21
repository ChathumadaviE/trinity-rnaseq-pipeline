process TRINITY {
    tag "Trinity Assembly"
    label 'heavy'
    
    publishDir "${params.outdir}/trinity_assembly", mode: params.publish_dir_mode, pattern: "Trinity.fasta"
    
    input:
    tuple val(sample_id), path(reads)
    
    output:
    path "Trinity.fasta", emit: assembly
    path "Trinity.fasta.gene_trans_map", emit: gene_trans_map, optional: true
    path "trinity_out_dir/", emit: trinity_dir, optional: true
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    def left_reads = reads[0]
    def right_reads = reads[1]
    def seqType = params.trinity_seqType ?: 'fq'
    def max_memory = params.trinity_max_memory ?: '100G'
    
    """
    Trinity \\
        --seqType $seqType \\
        --left $left_reads \\
        --right $right_reads \\
        --max_memory $max_memory \\
        --CPU $task.cpus \\
        --output trinity_out_dir \\
        --full_cleanup \\
        --verbose
    
    # Copy output to expected location
    cp trinity_out_dir/Trinity.fasta .
    
    # Generate gene-to-transcript map
    \$TRINITY_HOME/util/support_scripts/get_Trinity_gene_to_trans_map.pl Trinity.fasta > Trinity.fasta.gene_trans_map
    """
    
    stub:
    """
    echo ">TRINITY_DN0_c0_g1_i1" > Trinity.fasta
    echo "ATCGATCGATCGATCGATCG" >> Trinity.fasta
    touch Trinity.fasta.gene_trans_map
    """
}
