#!/bin/bash
#SBATCH -n 12                           # Number of cores requested
#SBATCH -N 1                            # Ensure that all cores are on one machine
#SBATCH -t 60                           # Runtime in minutes
#SBATCH -p serial_requeue               # Partition to submit to
#SBATCH --mem-per-cpu 1000              # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append              #
#SBATCH -o logs/hapcall_%j.out          # Standard out goes to this file
#SBATCH -e logs/hapcall_%j.err          # Standard err goes to this filehostname


# variables
scaffl=$1; export scaffl=$scaffl 
ploidy=$2; export ploidy=$ploidy 
popnam=$3; export popnam=$popnam 
refnam=$4; export refnam=$refnam
zchrom=$5; export zchrom=$zchrom
wchrom=$5; export wchrom=$zchrom



## Call ****************************************************************************************************************
# autosomes
cat ${scaffl} | egrep -v ${zchrom} | egrep -v ${wchrom} | xargs -n 1 -P 12 sh -c '
    ~/software/samtools-1.17/bcftools-1.17/bcftools call \
    -mO z \
    -o 2.1.call/$0.${popnam}.${refnam}.call.vcf.gz \
    --format-fields GQ,GP \
    2.0.mpileup/$0.${popnam}.${refnam}.mpileup.bcf
'
# Z-chromosome
~/software/samtools-1.17/bcftools-1.17/bcftools call -mO z \
    -o 2.1.call/${zchrom}.${popnam}.${refnam}.call.vcf.gz \
    --format-fields GQ,GP \
    --ploidy-file $ploidy \
    --samples-file support/sex/${popnam}.samples.sex \
    2.0.mpileup/${zchrom}.${popnam}.${refnam}.mpileup.bcf
# W-chromosome
~/software/samtools-1.17/bcftools-1.17/bcftools call -mO z \
    -o 2.1.call/${wchrom}.${popnam}.${refnam}.call.vcf.gz \
    --format-fields GQ,GP \
    --ploidy-file $ploidy \
    --samples-file support/sex/${popnam}.samples.sex \
    2.0.mpileup/${wchrom}.${popnam}.${refnam}.mpileup.bcf
