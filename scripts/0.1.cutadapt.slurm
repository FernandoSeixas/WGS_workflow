#!/bin/bash
#SBATCH -n 4   # Number of cores requested
#SBATCH -N 1    # Ensure that all cores are on one machine
#SBATCH -t 120  # Runtime in minutes
#SBATCH -p serial_requeue,shared  # Partition to submit to
#SBATCH --mem=8000 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o logs/cutadapt_%j.out # Standard out goes to this file
#SBATCH -e logs/cutadapt_%j.err # Standard err goes to this filehostname

prefix=$1

## CUTADAPT remove adapter sequences ====================
module load python/3.10.12-fasrc01
mamba activate cutadapt

cutadapt --cores=4 \
-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
-A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
-o 0.2.cutadapt/$prefix.r1.cutadapt.fastq.gz \
-p 0.2.cutadapt/$prefix.r2.cutadapt.fastq.gz \
0.1.fastq/$prefix.r1.fastq.gz \
0.1.fastq/$prefix.r2.fastq.gz \
> 0.2.cutadapt/$prefix.log

mamba deactivate 
