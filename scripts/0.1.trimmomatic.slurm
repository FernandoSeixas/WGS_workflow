#!/bin/bash
#SBATCH -n 4                            # Number of cores requested
#SBATCH -N 1                            # Ensure that all cores are on one machine
#SBATCH -t 600                          # Runtime in minutes
#SBATCH -p serial_requeue,shared        # Partition to submit to
#SBATCH --mem-per-cpu=2000              # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append              #
#SBATCH -o logs/trimmomatic_%j.out      # Standard out goes to this file
#SBATCH -e logs/trimmomatic_%j.err      # Standard err goes to this filehostname

prefix=$1

## TRIMMOMATIC remove adapter sequences ====================

## NexteraPE adapters
java -jar ~/software/qcontrol/Trimmomatic-0.39/trimmomatic-0.39.jar PE \
    -threads 4 \
    0.1.fastq/$prefix.r1.fastq.gz \
    0.1.fastq/$prefix.r2.fastq.gz \
    0.2.cutadapt/$prefix.r1.fastq.gz \
    0.2.cutadapt/$prefix.r1.unpaired.fastq.gz \
    0.2.cutadapt/$prefix.r2.fastq.gz \
    0.2.cutadapt/$prefix.r2.unpaired.fastq.gz \
    ILLUMINACLIP:/n/home12/fseixas/software/qcontrol/Trimmomatic-0.39/adapters/NexteraPE-PE.fa:2:30:10:2:True \
    MINLEN:36 > 0.2.cutadapt/$prefix.log

# ## Truseq adapters 
# java -jar ~/software/qcontrol/Trimmomatic-0.39/trimmomatic-0.39.jar PE \
#     -threads 4 \
#     0.1.fastq/$prefix.r1.fastq.gz \
#     0.1.fastq/$prefix.r2.fastq.gz \
#     0.2.cutadapt/$prefix.r1.fastq.gz \
#     0.2.cutadapt/$prefix.r1.unpaired.fastq.gz \
#     0.2.cutadapt/$prefix.r2.fastq.gz \
#     0.2.cutadapt/$prefix.r2.unpaired.fastq.gz \
#     ILLUMINACLIP:/n/home12/fseixas/software/qcontrol/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa:2:30:10:2:True \
#     MINLEN:36 > 0.2.cutadapt/$prefix.log


