#!/bin/bash
#SBATCH -n 21  # Number of cores requested
#SBATCH -N 1   # Ensure that all cores are on one machine
#SBATCH -t 300 # Runtime in minutes
#SBATCH -p serial_requeue,shared # Partition to submit to
#SBATCH --mem-per-cpu 1000 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o logs/mpileup_%j.out # Standard out goes to this file
#SBATCH -e logs/mpileup_%j.err # Standard err goes to this filehostname


## variables
scaffl=$1; export scaffl=$scaffl 
popnam=$2; export popnam=$popnam 
fasref=$3; export fasref=$fasref
refnam=$4; export refnam=$refnam


## mpileup
cat ${scaffl} | xargs -n 1 -P 21 sh -c '
    ~/software/samtools-1.17/bcftools-1.17/bcftools mpileup \
    --bam-list support/poplists/$popnam.$refnam.list \
    -r $0 \
    --fasta-ref $fasref \
    -O b \
    --min-MQ 20 --min-BQ 20 \
    --output 2.0.mpileup/$0.$popnam.$refnam.mpileup.bcf \
    -a FORMAT/DP,FORMAT/AD
'
