process ANNOTATION {
    tag "Functional Annotation"
    label 'process_high'
    
    publishDir "${params.outdir}/annotation", mode: params.publish_dir_mode
    
    input:
    path protein_file
    
    output:
    path "*.blastp.outfmt6", emit: blastp, optional: true
    path "*.interproscan.xml", emit: interpro, optional: true
    path "annotation_report.txt", emit: report
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    """
    # Create annotation report
    cat > annotation_report.txt << 'EOF'
    Annotation Summary
    ==================
    Input proteins: $protein_file
    Processing date: \$(date)
    
    Annotation tools to run:
    - BLAST (UniProt)
    - InterProScan
    - KEGG (optional)
    
    Note: Full annotation requires external databases
    EOF
    
    # Optional: Run BLAST if database available
    if command -v blastp &> /dev/null && [ -d "/databases/uniprot" ]; then
        blastp -query $protein_file \\
            -db /databases/uniprot/uniprot \\
            -evalue 1e-5 \\
            -num_threads $task.cpus \\
            -outfmt 6 \\
            -out proteins.blastp.outfmt6
    fi
    """
    
    stub:
    """
    echo "Annotation stub completed" > annotation_report.txt
    touch proteins.blastp.outfmt6
    touch proteins.interproscan.xml
    """
}
