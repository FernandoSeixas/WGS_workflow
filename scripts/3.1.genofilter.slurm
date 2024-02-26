#!/bin/bash
#SBATCH -n 4                            # Number of cores requested
#SBATCH -N 1                            # Ensure that all cores are on one machine
#SBATCH -t 300                          # Runtime in minutes
#SBATCH -p serial_requeue,shared        # Partition to submit to
#SBATCH --mem-per-cpu=1000              # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append              # 
#SBATCH -o logs/gengen_%j.out           # Standard out goes to this file
#SBATCH -e logs/gengen_%j.err           # Standard err goes to this filehostname


## load modules ********************************************************************************************************
module load python/3.10.12-fasrc01

## Variables
refnam=$1; export refnam=$refnam
chromn=$2; export chromn=$chromn


## Filter geno *********************************************************************************************************
python ~/software/genomics_general/filterGenotypes.py \
    -i 3.0.vcf2geno/${chromn}.${refnam}.geno.gz \
    -o 3.1.genofilter/${chromn}.${refnam}.filter.geno.gz \
    -t 1 \
    -if phased \
    -of phased 
