#!/bin/bash

# Trinity Nextflow Pipeline - Setup Script
# This script helps set up the pipeline environment

set -e

echo "================================"
echo "Trinity Pipeline Setup"
echo "================================"
echo ""

# Check if Nextflow is installed
if ! command -v nextflow &> /dev/null; then
    echo "Installing Nextflow..."
    curl -s https://get.nextflow.io | bash
    chmod +x nextflow
    echo "✓ Nextflow installed"
else
    echo "✓ Nextflow already installed: $(nextflow -version | head -n1)"
fi

echo ""

# Check if Docker is installed
if command -v docker &> /dev/null; then
    echo "✓ Docker found: $(docker --version)"
    echo ""
    echo "To use Docker images, ensure Docker daemon is running"
else
    echo "⚠ Docker not found. You'll need to install Trinity and dependencies locally"
    echo "  or use Singularity instead"
fi

echo ""

# Create data directory
if [ ! -d "data" ]; then
    mkdir -p data
    echo "✓ Created data/ directory"
fi

# Create results directory
if [ ! -d "results" ]; then
    mkdir -p results
    echo "✓ Created results/ directory"
fi

echo ""
echo "================================"
echo "Setup Complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Place your FASTQ files in the data/ directory"
echo "2. Run the pipeline:"
echo ""
echo "   nextflow run nextflow.nf -profile docker --reads 'data/*_{1,2}.fastq.gz'"
echo ""
echo "Or with custom parameters:"
echo ""
echo "   nextflow run nextflow.nf -profile docker -params-file params.yml"
echo ""
