#!/bin/bash

# Quick test of the Trinity Nextflow pipeline
# This runs the pipeline with stub/dry-run mode

echo "================================"
echo "Trinity Pipeline - Quick Test"
echo "================================"
echo ""

# Create test data directory
mkdir -p test_data

# Check if test data exists, if not create dummy files
if [ ! -f "test_data/test_1.fastq.gz" ]; then
    echo "Creating test FASTQ files..."
    # Create simple gzipped FASTQ files
    {
        echo "@read1"
        echo "ATCGATCGATCGATCGATCG"
        echo "+"
        echo "IIIIIIIIIIIIIIIIIII"
    } | gzip > test_data/test_1.fastq.gz
    
    {
        echo "@read1"
        echo "GCTAGCTAGCTAGCTAGCTA"
        echo "+"
        echo "IIIIIIIIIIIIIIIIIII"
    } | gzip > test_data/test_2.fastq.gz
    
    echo "✓ Test data created"
fi

echo ""
echo "Running pipeline in stub mode (no execution)..."
echo ""

nextflow run nextflow.nf \
    -profile docker,standard \
    --reads 'test_data/test_{1,2}.fastq.gz' \
    --outdir test_results/ \
    -stub-run \
    -with-report test_results/report.html \
    -with-timeline test_results/timeline.html

echo ""
echo "================================"
echo "Test Complete!"
echo "================================"
echo ""
echo "To run the actual pipeline with your data:"
echo "nextflow run nextflow.nf -profile docker --reads 'data/*_{1,2}.fastq.gz'"
echo ""
