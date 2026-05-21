process TRANSDECODERIZE {
    tag "TransDecoder Prediction"
    label 'process_high'
    
    publishDir "${params.outdir}/transdecoder", mode: params.publish_dir_mode
    
    input:
    path assembly
    
    output:
    path "*.transdecoder.pep", emit: proteins
    path "*.transdecoder.cds", emit: cds
    path "*.transdecoder.gff3", emit: gff3
    path "*.transdecoder.mRNA", emit: mrna, optional: true
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    def min_prot_len = params.transdecoder_min_prot_length ?: 100
    
    """
    # Extract longest ORFs
    TransDecoder.LongOrfs \\
        -t $assembly \\
        -m $min_prot_len \\
        --cpu $task.cpus
    
    # Predict coding regions
    TransDecoder.Predict \\
        -t $assembly \\
        --cpu $task.cpus \\
        --single_best_orf
    
    # Generate outputs with meaningful names
    BASENAME=\$(basename $assembly .fasta)
    """
    
    stub:
    def basename = assembly.toString().replaceAll(/\.fasta$/, "")
    """
    touch ${basename}.transdecoder.pep
    touch ${basename}.transdecoder.cds
    touch ${basename}.transdecoder.gff3
    touch ${basename}.transdecoder.mRNA
    """
}
