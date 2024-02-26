#!/bin/bash
#SBATCH -n 8                                # Number of cores requested
#SBATCH -N 1                                # Ensure that all cores are on one machine
#SBATCH -t 600                              # Runtime in minutes
#SBATCH -p shared                           # Partition to submit to
#SBATCH --mem-per-cpu=4000                  # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append                  #
#SBATCH -o logs/bamp_%j.out                 # Standard out goes to this file
#SBATCH -e logs/bamp_%j.err                 # Standard err goes to this filehostname

file=$1
echo $file

## PROCESSING BAM FILES ====================
# convert to bam
~/software/samtools-1.17/samtools-1.17/samtools view \
    --threads 8 \
    --output-fmt BAM \
    -o 1.0.bwa/$file.bam \
    1.0.bwa/$file.sam
# sort
~/software/samtools-1.17/samtools-1.17/samtools sort \
    --threads 8 \
    --output-fmt BAM \
    -o 1.1.sort/$file.sort.bam \
    1.0.bwa/$file.bam
# move sam file to sam folder
mv 1.0.bwa/$file.sam 1.0.bwa/sam/
