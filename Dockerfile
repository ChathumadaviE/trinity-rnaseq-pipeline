# Use Trinity official image or build from Dockerfile
FROM trinity-rnaseq:latest

# Install additional tools
RUN apt-get update && apt-get install -y \
    bowtie2 \
    samtools \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install multiqc

# Set working directory
WORKDIR /data

# Default command
CMD ["/bin/bash"]
