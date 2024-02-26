#!/bin/bash
#SBATCH -n 4               # Number of cores requested
#SBATCH -N 1               # Ensure that all cores are on one machine
#SBATCH -t 30              # Runtime in minutes
#SBATCH -p serial_requeue  # Partition to submit to
#SBATCH --mem-per-cpu 4000 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o qualimap_%j.out # Standard out goes to this file
#SBATCH -e qualimap_%j.err # Standard err goes to this filehostname


## qualimap ==================================================

# load modules
module load Java/1.8

# define variables 
prefix=$1
refnam=$2

# run qualimap
~/software/qcontrol/qualimap_v2.2.1/qualimap bamqc \
    --java-mem-size=4G \
    -bam $prefix.$refnam.sort.bam \
    -nt 4 \
    -outformat HTML \
    -outdir qualimap/$prefix \
    -outfile $prefix
