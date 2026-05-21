process SALMON {
    tag "$sample_id"
    label 'process_high'
    
    publishDir "${params.outdir}/salmon_quantification", mode: params.publish_dir_mode
    
    input:
    path assembly
    tuple val(sample_id), path(reads)
    
    output:
    path "${sample_id}/", emit: quant_dir
    path "${sample_id}/quant.sf", emit: quant
    path "${sample_id}/quant.genes.sf", emit: gene_quant, optional: true
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    def left_reads = reads[0]
    def right_reads = reads[1]
    def libType = params.salmon_libType ?: 'A'
    def kmer = params.salmon_kmer ?: 31
    
    """
    salmon index \\
        -t $assembly \\
        -i assembly_index \\
        -k $kmer \\
        -p $task.cpus
    
    salmon quant \\
        -i assembly_index \\
        -l $libType \\
        -1 $left_reads \\
        -2 $right_reads \\
        -p $task.cpus \\
        -o ${sample_id} \\
        --validateMappings \\
        --seqBias \\
        --gcBias
    """
    
    stub:
    """
    mkdir -p ${sample_id}
    echo "Name\tLength\tEffectiveLength\tTPM\tNumReads" > ${sample_id}/quant.sf
    echo "TRINITY_DN0_c0_g1_i1\t100\t95\t10.5\t1000" >> ${sample_id}/quant.sf
    """
}
