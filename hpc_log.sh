# Installation

# Load modules
module load python/3.11
module load rust
module load postgresql

# Create nf-core venv
python -m venv nf-core-env
source nf-core-env/bin/activate

# Install nf-core
python -m pip install nf_core==2.13

# Set name of pipeline and load apptainer and nextflow
export NFCORE_PL=ampliseq
export PL_VERSION=2.14.0
module load nextflow/24.10.2
module load apptainer/1.3.5

# Create a directory to store image and set an environmental variable to it
mkdir -p </path/to/cashedir>
export NXF_SINGULARITY_CACHEDIR=</path/to/cashedir>

# Issue with prompt_toolkit. To resolve:
pip uninstall prompt_toolkit -y
pip install prompt_toolkit==3.0.36

# Download ampliseq to the /scratch directory and put images in the cache directory
nf-core pipelines download --container-cache-utilisation amend --container-system singularity --compress none -r ${PL_VERSION} -p 6 ${NFCORE_PL}

# Create environmental variable for slurm account
export SLURM_ACCOUNT=<account>

# Run ampliseq using test profile
nextflow run nf-core-${NFCORE_PL}_${PL_VERSION}/2_14_0/  -profile test,singularity,alliance_canada  --outdir ${NFCORE_PL}_OUTPUT -resume

# Run ampliseq + differential abundance analysis
#!/bin/bash
#SBATCH --job-name=ampliseq
#SBATCH --output=ampliseq_%j.out
#SBATCH --error=ampliseq_%j.err
#SBATCH --mem=3g
#SBATCH --time=12:00:00

# Load modules
module load python/3.11 rust postgresql nextflow/24.10.2 apptainer/1.3.5
source nf-core-env/bin/activate

# Set environment variables
export NFCORE_PL=ampliseq
export PL_VERSION=2.14.0
export NXF_SINGULARITY_CACHEDIR=</path/to/cashedir>
export SLURM_ACCOUNT=<account>

# Run ampliseq
nextflow run nf-core-${NFCORE_PL}_${PL_VERSION}/2_14_0/ \
        -profile singularity,alliance_canada \
        --input_folder "./fastq_input/" \
        --extension "*_{1,2}.fastq.gz" \
        --FW_primer 'TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGCCTACGGGNGGCWGCAG' \
        --RV_primer 'GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGACTACHVGGGTATCTAATCC' \
        --metadata "./metadata.tsv" \
        --outdir "./results" \
        --ancom \
        --ancombc \
        -resume

# After removing poor quality and unpaired samples, run ampliseq with --trunc_qmin 15
# Run ampliseq + differential abundance analysis
#!/bin/bash
#SBATCH --job-name=ampliseq_quickfix
#SBATCH --output=ampliseq_%j.out
#SBATCH --error=ampliseq_%j.err
#SBATCH --mem=3g
#SBATCH --time=12:00:00

# Load modules
module load python/3.11 rust postgresql nextflow/24.10.2 apptainer/1.3.5
source nf-core-env/bin/activate

# Set environment variables
export NFCORE_PL=ampliseq
export PL_VERSION=2.14.0
export NXF_SINGULARITY_CACHEDIR=</path/to/cashedir>
export SLURM_ACCOUNT=<account>

# Run ampliseq
nextflow run nf-core-${NFCORE_PL}_${PL_VERSION}/2_14_0/ \
        -profile singularity,alliance_canada \
        --input_folder "./fastq_input/" \
        --extension "*_{1,2}.fastq.gz" \
        --FW_primer 'TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGCCTACGGGNGGCWGCAG' \
        --RV_primer 'GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGACTACHVGGGTATCTAATCC' \
        --metadata "./metadata.tsv" \
        --metadata_category "VISIT,SUBJECT" \
        --metadata_category_barplot "VISIT" \
        --trunc_qmin 15 \
        --outdir "./results" \
        --ancom \
        --ancombc \
        -resume