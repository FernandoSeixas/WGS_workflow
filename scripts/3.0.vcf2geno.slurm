#!/bin/bash
#SBATCH -n 1                                # Number of cores requested
#SBATCH -N 1                                # Ensure that all cores are on one machine
#SBATCH -t 300                              # Runtime in minutes
#SBATCH -p serial_requeue,shared            # Partition to submit to
#SBATCH --mem-per-cpu 4000                  # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append                  #
#SBATCH -o logs/vcf2geno_%j.out             # Standard out goes to this file
#SBATCH -e logs/vcf2geno_%j.err             # Standard err goes to this filehostname


# load modules
module load python/3.10.12-fasrc01

# arguments
refnam=$1; export refnam=$refnam
chroms=$2; export chroms=$chroms
zchrom=$3; export zchrom=$zchrom
wchrom=$4; export wchrom=$wchrom
ploidy=$5; export ploidy=$ploidy


##### vcf2geno *********************************************************************************************************

# AUTOSOMES
if [[ $chroms != $zchrom && $chroms != $wchrom ]]
then
    python ~/software/popgen/genomics_general/VCF_processing/parseVCF.py \
    -i 2.3.merge/${chroms}.${refnam}.simplify.vcf.gz \
    --skipIndels |
    ~/software/samtools-1.17/htslib-1.17/bgzip > 3.0.vcf2geno/${chroms}.${refnam}.geno.gz
fi

# Z-CHROMOSOME
if [ $chroms = $zchrom ]
then
    python ~/software/popgen/genomics_general/VCF_processing/parseVCF.py \
    -i 2.3.merge/${zchrom}.${refnam}.simplify.vcf.gz \
    --skipIndels \
    --ploidyFile ${ploidy} |
    ~/software/samtools-1.17/htslib-1.17/bgzip > 3.0.vcf2geno/${zchrom}.${refnam}.geno.gz
fi

# # W-CHROMOSOME
# if [ $chroms = "1W" ]
# then
#     python /n/home12/fseixas/software/popgen/genomics_general/VCF_processing/parseVCF.py \
#     -i 2.3.merge/1W.$refnam.simplify.vcf.gz \
#     --skipIndels \
#     --ploidyFile /n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/0.data/support/ploidy/samples.allpop.X.ploidy |
#     bgzip > 3.0.vcf2geno/1W.$refnam.geno.gz
# fi