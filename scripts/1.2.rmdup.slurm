#!/bin/bash
#SBATCH -J rmdup                  # A single job name for the array
#SBATCH -n 8                      # Number of cores requested
#SBATCH -N 1                      # Ensure that all cores are on one machine
#SBATCH -t 600                    # Runtime in minutes
#SBATCH -p shared                 # Partition to submit to
#SBATCH --mem=24000               # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append        #
#SBATCH -o rmdup_%j.out           # Standard out goes to this file
#SBATCH -e rmdup_%j.err           # Standard err goes to this filehostname

## sambamba remove duplicates ----
bash x"${SLURM_ARRAY_TASK_ID}".sh

