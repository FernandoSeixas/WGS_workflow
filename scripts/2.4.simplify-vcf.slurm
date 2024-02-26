#!/bin/bash
#SBATCH -n 24                               # Number of cores requested
#SBATCH -N 1                                # Ensure that all cores are on one machine
#SBATCH -t 60                               # Runtime in minutes
#SBATCH -p serial_requeue,shared            # Partition to submit to
#SBATCH --mem-per-cpu 4000                  # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append                  # 
#SBATCH -o logs/snpset_%j.out               # Standard out goes to this file
#SBATCH -e logs/snpset_%j.err               # Standard err goes to this filehostname


# ## load module
module load python/3.10.12-fasrc01
mamba activate vcftools
# module load tabix/0.2.6-fasrc01
# module load plink/1.90-fasrc01
# module load vcftools/0.1.14-fasrc01

## Variables
scaffl=$1; export scaffl=$scaffl; echo $scaffl;
refnam=$2; export refnam=$refnam; echo $refnam;
Zchrom=$3; export Zchrom=$Zchrom; echo $Zchrom; 
Wchrom=$4; export Wchrom=$Wchrom; echo $Wchrom; 



## Simplify vcf in plink ***********************************************************************************************

## run through plink to simplify vcf
#/ this recodes SNPs, that were not biallelic but become bi-allelic because some individuals were dropped
#/ also get rid of sites with excessive missing data (>0.8)
#        --chr-set 31 \
cat ${scaffl} | egrep -v ${Wchrom} | xargs -n 1 -P 12 sh -c '
    ~/software/plink_1.9/plink \
        --threads 2 \
        --double-id \
        --vcf 2.3.merge/$0.${refnam}.merge.vcf.gz \
        --geno 0.5 \
        --allow-extra-chr \
        --recode vcf-iid \
        --out 2.3.merge/$0.${refnam}.simplify
'
rm 2.3.merge/*.${refnam}.simplify.log
rm 2.3.merge/*.${refnam}.simplify.nosex

## Correct samples ploidy for the Z-chromosome & W-Chromosome ********************************************************
# check vcf-fix-ploify to see how to generate the ploidy and sex files
# also check http://vcftools.sourceforge.net/perl_module.html
cat 2.3.merge/${Zchrom}.${refnam}.simplify.vcf | vcf-fix-ploidy \
    -p support/vcfFixPloidy.file \
    -s support/samples.sex \
    > tmpZ.${refnam}; 
mv tmpZ.${refnam} 2.3.merge/${Zchrom}.${refnam}.simplify.vcf
# cat 2.3.merge/${Wchrom}.${refnam}.simplify.vcf | vcf-fix-ploidy \
#     -p support/vcfFixPloidy.file \
#     -s support/samples.sex \
#     > tmpW.${refnam}; 
# mv tmpW.${refnam} 2.3.merge/${Wchrom}.${refnam}.simplify.vcf

# ## compress & index
cat ${scaffl} | xargs -n 1 -P 1 sh -c ' ~/software/samtools-1.17/htslib-1.17/bgzip -f 2.3.merge/$0.${refnam}.simplify.vcf '
cat ${scaffl} | xargs -n 1 -P 1 sh -c ' ~/software/samtools-1.17/htslib-1.17/tabix -f -p vcf 2.3.merge/$0.${refnam}.simplify.vcf.gz '

