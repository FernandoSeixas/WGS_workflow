#!/bin/bash
#SBATCH -n 12                            # Number of cores requested
#SBATCH -N 1                             # Ensure that all cores are on one machine
#SBATCH -t 1200                          # Runtime in minutes
#SBATCH -p serial_requeue,shared         # Partition to submit to
#SBATCH --mem-per-cpu 4000               # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append               # 
#SBATCH -o logs/vcfmerge_%j.out          # Standard out goes to this file
#SBATCH -e logs/vcfmerge_%j.err          # Standard err goes to this filehostname


## variables
scaffl=$1; export scaffl=$scaffl
refnam=$2; export refnam=$refnam


## create vcf lists per scaffold
for scaffold in `cat $scaffl `; do 
	ls 2.2.filter/2.2.3.normfilter/$scaffold.*.${refnam}.normfilter.vcf.gz > 2.2.filter/2.2.3.normfilter/$scaffold.list; 
done

## merge
cat ${scaffl} | xargs -n 1 -P 12 sh -c '
	~/software/samtools-1.17/bcftools-1.17/bcftools merge \
	--file-list 2.2.filter/2.2.3.normfilter/$0.list \
	--merge snps \
	-O z \
	-o 2.3.merge/$0.${refnam}.merge.vcf.gz
'

## Index
cat ${scaffl} | xargs -n 1 -P 12 sh -c '~/software/samtools-1.17/htslib-1.17/tabix -f -p vcf 2.3.merge/$0.${refnam}.merge.vcf.gz'
