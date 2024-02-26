#!/bin/bash
#SBATCH -J rmdup  # A single job name for the array
#SBATCH -n 1      # Number of cores requested
#SBATCH -N 1      # Ensure that all cores are on one machine
#SBATCH -t 300    # Runtime in minutes
#SBATCH -p serial_requeue,unrestricted,shared  # Partition to submit to
#SBATCH --mem=32000 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o logs/rmdup_%A_%a.out # Standard out goes to this file
#SBATCH -e logs/rmdup_%A_%a.err # Standard err goes to this filehostname

module load Java/1.8

prefix=$1
refnam=$2

java -jar ~/software/picard.2.25.7/picard.jar MarkDuplicates \
    I=1.1.sort/${prefix}.${refnam}.sort.bam \
    O=1.2.rmdup/${prefix}.${refnam}.rmdup.bam \
    M=1.2.rmdup/${prefix}.${refnam}.rmdup.txt

samtools index -b 1.2.rmdup/${prefix}.${refnam}.rmdup.bam