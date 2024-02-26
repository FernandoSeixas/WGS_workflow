#!/bin/bash
#SBATCH -n 12                           # Number of cores requested
#SBATCH -N 1                            # Ensure that all cores are on one machine
#SBATCH -t 300                          # Runtime in minutes
#SBATCH -p serial_requeue,shared        # Partition to submit to
#SBATCH --mem-per-cpu 1000              # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append              # 
#SBATCH -o logs/filter_%j.out           # Standard out goes to this file
#SBATCH -e logs/filter_%j.err           # Standard err goes to this filehostname


# variables
scaffl=$1; export scaffl=$scaffl
popnam=$2; export popnam=$popnam
fasref=$3; export fasref=$fasref
refnam=$4; export refnam=$refnam



## markfilter
cat ${scaffl} | xargs -n 1 -P 12 sh -c '
~/software/samtools-1.17/bcftools-1.17/bcftools filter --include "'"
    type!='"'indel'"' && STRLEN(REF) == 1 && QUAL >= 20 && MQ >= 20 && FMT/DP >= 8 && FMT/GQ >=20 || 
    type!='"'indel'"' && STRLEN(REF) == 1 && QUAL >= 20 && MQ >= 20 && FMT/DP >= 8 && FMT/GT=='"'0/0'"' || 
    type!='"'indel'"' && STRLEN(REF) == 1 && QUAL >= 20 && MQ >= 20 && FMT/DP >= 4 && FMT/GT=='"'0'"' || 
    type!='"'indel'"' && STRLEN(REF) == 1 && QUAL >= 20 && MQ >= 20 && FMT/DP >= 4 && FMT/GT=='"'1'"' || 
    type!='"'indel'"' && STRLEN(REF) == 1 && QUAL >= 20 && MQ >= 20 && FMT/DP >= 4 && FMT/GT=='"'2'"' "'" \
    --SnpGap 5 --set-GTs . -O z -o 2.2.filter/2.2.1.markfilter/$0.${popnam}.${refnam}.markfilter.vcf.gz 2.1.call/$0.${popnam}.${refnam}.call.vcf.gz
'

## apply filter
cat ${scaffl} | xargs -n 1 -P 12 sh -c '
~/software/samtools-1.17/bcftools-1.17/bcftools view \
    --apply-filters "PASS" \
    -O z \
    -o 2.2.filter/2.2.2.passfilter/$0.${popnam}.${refnam}.passfilter.vcf.gz \
    2.2.filter/2.2.1.markfilter/$0.${popnam}.${refnam}.markfilter.vcf.gz
'

## normalize data and remove indels
cat ${scaffl} | xargs -n 1 -P 12 sh -c '
~/software/samtools-1.17/bcftools-1.17/bcftools view \
    2.2.filter/2.2.2.passfilter/$0.${popnam}.${refnam}.passfilter.vcf.gz | \
    grep -v "INDEL" | \
    ~/software/samtools-1.17/bcftools-1.17/bcftools norm --multiallelics +any -f $fasref | \
    ~/software/samtools-1.17/htslib-1.17/bgzip > 2.2.filter/2.2.3.normfilter/$0.${popnam}.${refnam}.normfilter.vcf.gz
'

## index files
cat ${scaffl} | xargs -n 1 -P 12 sh -c '~/software/samtools-1.17/htslib-1.17/tabix -f 2.2.filter/2.2.3.normfilter/$0.${popnam}.${refnam}.normfilter.vcf.gz'
