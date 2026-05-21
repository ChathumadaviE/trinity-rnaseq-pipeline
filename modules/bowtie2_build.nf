process BOWTIE2_BUILD {
    tag "Build Bowtie2 Index"
    label 'process_medium'
    
    publishDir "${params.outdir}/bowtie2_index", mode: params.publish_dir_mode
    
    input:
    path assembly
    
    output:
    path "*.bt2*", emit: index
    path "assembly.fasta", emit: reference
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    """
    cp $assembly assembly.fasta
    bowtie2-build --threads $task.cpus assembly.fasta assembly
    """
    
    stub:
    """
    cp $assembly assembly.fasta
    touch assembly.1.bt2
    touch assembly.2.bt2
    touch assembly.3.bt2
    touch assembly.4.bt2
    touch assembly.rev.1.bt2
    touch assembly.rev.2.bt2
    """
}
