#!/bin/bash
#SBATCH -n 1                            # Number of cores requested
#SBATCH -N 1                            # Ensure that all cores are on one machine
#SBATCH -t 1200                         # Runtime in minutes
#SBATCH -p shared                       # Partition to submit to
#SBATCH --mem=12000                     # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append              # 
#SBATCH -o logs/realign_%j.out          # Standard out goes to this file
#SBATCH -e logs/realign_%j.err          # Standard err goes to this filehostname

# load modules
# module load jdk/20.0.1-fasrc01

# variables
prefix=$1
fasref=$2
refnam=$3

# RealignerTargetCreator
java -Xmx2g -jar ~/software/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar \
    -T RealignerTargetCreator \
    -R ${fasref} \
    -I 1.2.rmdup/${prefix}.${refnam}.rmdup.bam \
    -o 1.3.realign/${prefix}.${refnam}.intervals 

# IndelRealigner
java -Xmx4g -jar ~/software/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar \
    -T IndelRealigner \
    --filter_bases_not_stored \
    -R ${fasref} \
    -I 1.2.rmdup/${prefix}.${refnam}.rmdup.bam \
    -targetIntervals 1.3.realign/${prefix}.${refnam}.intervals \
    -o 1.3.realign/${prefix}.${refnam}.realigned.bam
