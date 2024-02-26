#!/bin/bash
#SBATCH -J bwa                                  # A single job name for the array
#SBATCH -n 16                                   # Number of cores requested
#SBATCH -N 1                                    # Ensure that all cores are on one machine
#SBATCH -t 2400                                 # Runtime in minutes
#SBATCH -p shared                               # Partition to submit to
#SBATCH --mem=32000                             # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o logs/bwa_%A_%a.out                   # Standard out goes to this file
#SBATCH -e logs/bwa_%A_%a.err                   # Standard err goes to this filehostname

## BWA - map to reference ----
refnam=$1
bash code/bwa.launch.${refnam}."${SLURM_ARRAY_TASK_ID}".sh

