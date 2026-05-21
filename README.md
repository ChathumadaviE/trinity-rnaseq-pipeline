# trinity-rnaseq-pipeline
Trinity De novo Transcriptome Assembly Pipeline
A comprehensive Nextflow pipeline for de novo transcriptome assembly using Trinity, including quality control, assembly, annotation, and quantification steps.

Features
Quality Control: FastQC analysis on raw and trimmed reads
Read Trimming: Trimmomatic for adapter and quality trimming
De novo Assembly: Trinity for transcript assembly
Assembly Quality: BUSCO assessment of assembly completeness
Read Alignment: Bowtie2 alignment and BAM file generation
Transcript Quantification: Salmon for fast transcript abundance quantification
Protein Prediction: TransDecoder for coding region identification
Functional Annotation: BLAST and InterProScan for functional annotation
Quality Reports: MultiQC integration for comprehensive quality reports
Pipeline Overview
Raw Reads (FASTQ)
    ↓
[FastQC] → Quality Assessment
    ↓
[Trimmomatic] → Read Trimming
    ↓
[FastQC] → Trimmed Read QC
    ↓
[Trinity] → De novo Assembly
    ├─→ [BUSCO] → Assembly Quality
    ├─→ [Bowtie2 Build Index]
    │   ↓
    │   [Bowtie2 Align] → BAM Files
    ├─→ [Salmon] → Quantification
    ├─→ [TransDecoder] → Protein Prediction
    └─→ [BLAST/InterProScan] → Annotation
    ↓
[MultiQC] → Final QC Report
Installation
Requirements
Nextflow >= 22.10.0
Docker or Singularity (recommended) OR local Trinity/dependencies installation
Quick Start with Docker
# Clone repository
git clone https://github.com/ChathumadaviE/trinity-rnaseq-pipeline.git
cd trinity-rnaseq-pipeline

# Run with Docker (recommended)
nextflow run nextflow.nf \
    -profile docker,standard \
    --reads 'data/sample_{1,2}.fastq.gz' \
    --outdir results/
Installation of Dependencies (Local)
If not using Docker, install these tools:

# Install Conda/Mamba (recommended)
conda create -n trinity-pipeline trinity fastqc trimmomatic bowtie2 salmon samtools busco multiqc -c bioconda

# Activate environment
conda activate trinity-pipeline

# Install TransDecoder
git clone https://github.com/TransDecoder/TransDecoder.git
cd TransDecoder
make
Usage
Basic Usage
nextflow run nextflow.nf \
    -profile docker \
    --reads 'data/*_{1,2}.fastq.gz' \
    --outdir results/
With Custom Parameters
nextflow run nextflow.nf \
    -profile docker,slurm \
    --reads 'data/samples_{1,2}.fastq.gz' \
    --outdir results/ \
    --trinity_max_memory 100G \
    --busco_lineage eukarya \
    --max_cpus 32
Input Parameters
Parameter	Description	Default
--reads	Input read pairs (required)	None
--outdir	Output directory	./results
--trinity_max_memory	Memory for Trinity	100G
--trinity_cpu	CPUs for Trinity	32
--busco_lineage	BUSCO lineage	eukarya
--salmon_kmer	k-mer size for Salmon	31
--transdecoder_min_prot_length	Min protein length	100
--max_memory	Max memory per process	120GB
--max_cpus	Max CPUs per process	32
--max_time	Max time per process	48h
Execution Profiles
standard: Local execution (default)
docker: Docker containers
singularity: Singularity containers
slurm: SLURM HPC cluster
Run with Different Profiles
# Docker + standard local execution
nextflow run nextflow.nf -profile docker,standard --reads '*.fastq.gz'

# Singularity + SLURM HPC
nextflow run nextflow.nf -profile singularity,slurm --reads '*.fastq.gz'

# Local execution with installed tools
nextflow run nextflow.nf -profile standard --reads '*.fastq.gz'
Output Structure
results/
├── fastqc/                    # FastQC quality reports
├── trimmed_reads/             # Trimmed FASTQ files
├── trinity_assembly/          # Trinity assembly output
│   └── Trinity.fasta          # Final transcriptome assembly
├── busco/                     # BUSCO assessment results
├── bowtie2_index/             # Bowtie2 index files
├── bam_files/                 # Read alignment BAM files
├── salmon_quantification/     # Salmon quantification results
├── transdecoder/              # Protein predictions
├── annotation/                # Functional annotations
├── multiqc/                   # MultiQC aggregated reports
└── pipeline_*                 # Nextflow execution reports
    ├── timeline.html
    ├── report.html
    ├── trace.txt
    └── dag.svg
Example Data
Create test data:

mkdir -p data

# Generate small test reads
art_illumina -ss HS25 -i reference.fasta -l 100 -f 10 -m 300 -s 20 -o data/sample

# Or download from existing datasets:
# SRA: https://www.ncbi.nlm.nih.gov/sra
# iGenomes: https://ewels.github.io/AWS-iGenomes/
Troubleshooting
Issue: "Trinity not found"
Solution: Ensure Trinity is installed or use Docker profile:

nextflow run nextflow.nf -profile docker --reads '*.fastq.gz'
Issue: "Out of memory"
Solution: Increase Trinity memory:

nextflow run nextflow.nf -profile docker --reads '*.fastq.gz' --trinity_max_memory 150G
Issue: BUSCO database not found
Solution: Download BUSCO database manually:

busco --list-datasets
busco -l eukarya_odb10 --download
Configuration Files
nextflow.config
Main configuration file with process definitions, resource allocation, and execution profiles.

params.yml (optional)
Create custom parameters file:

reads: 'data/*_{1,2}.fastq.gz'
outdir: './results'
trinity_max_memory: '100G'
trinity_cpu: 32
busco_lineage: 'eukarya'
max_memory: '120GB'
max_cpus: 32
Run with:

nextflow run nextflow.nf -params-file params.yml
Advanced Usage
Resume Failed Pipeline
nextflow run nextflow.nf -resume \
    --reads 'data/*_{1,2}.fastq.gz'
Generate DAG
nextflow run nextflow.nf -profile docker --reads '*.fastq.gz' --dag
Dry Run
nextflow run nextflow.nf -profile docker --reads '*.fastq.gz' -n
Performance Optimization
For Large Assemblies
nextflow run nextflow.nf -profile slurm \
    --reads 'data/*_{1,2}.fastq.gz' \
    --trinity_max_memory 200G \
    --trinity_cpu 64 \
    --max_memory 256GB \
    --max_cpus 64
For Quick Testing
nextflow run nextflow.nf -profile docker \
    --reads 'subset/*_{1,2}.fastq.gz' \
    --outdir results_test/
Citation
If you use this pipeline, please cite:

Haas et al. (2013). De novo transcript sequence reconstruction from RNA-seq using the Trinity platform for reference generation and analysis. Nature Protocols 8, 1494-1512.
Grabherr et al. (2011). Full-length transcriptome assembly from RNA-Seq data without a reference genome. Nature Biotechnology 29, 644-652.
License
MIT License - see LICENSE file for details

Support
For issues, questions, or contributions, please visit: https://github.com/ChathumadaviE/trinity-rnaseq-pipeline/issues

References
Trinity: https://trinityrnaseq.sourceforge.net/
Nextflow: https://www.nextflow.io/
BUSCO: https://busco.ezlab.org/
Salmon: https://salmon.readthedocs.io/
TransDecoder: https://transdecoder.github.io/
