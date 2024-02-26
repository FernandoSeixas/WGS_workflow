
################################################# VCF-2-GENO ###########################################################

#/ Create directories
mkdir 3.0.vcf2geno
mkdir 3.1.genofilter
mkdir 3.2.phase
mkdir 3.3.phaseVariable

#/ Variables
# refnam="driulv1"
# fasref="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/driulv1/Diul.assembly.v1.1.fasta"
# scaffl="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/driulv1/driulv1.scaffolds.txt"

refnam="hmelv25"
fasref="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/Heliconius_melpomene_melpomene_Hmel2.5.scaffolds.fa"
scaffl="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt"
ploidy="/n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/0.data/support/ploidy/samples.allpop.X.ploidy"
export refnam=$refnam
export fasref=$fasref
export scaffl=$scaffl
export ploidy=$ploidy



#/ vcf2geno
cat ${scaffl} | xargs -n 1 sh -c '
    sbatch ~/code/heliconius_seixas/wgs_workflow/scripts/3.0.vcf2geno.slurm $refnam $0 Hmel221001o none $ploidy
'

#/ filter
cat ${scaffl} | xargs -n 1 sh -c '
    sbatch ~/code/heliconius_seixas/wgs_workflow/scripts/3.1.genofilter.slurm $refnam $0
'
#/ geno2vcf
cat ${scaffl} | xargs -n 1 sh -c '
    sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/popgen/3.2.geno2vcf.slurm $0 $refnam $snpset
'

# #/ phase [beagle]
# cat ${scaffl} | \
#     xargs -n 1 sh -c '
#     sbatch o $0 $refnam $snpset
# '
# #/ convert back to geno
# sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/popgen/3.3.vcf2geno.slurm $refnam $snpset
# #/ variable sites
# sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/popgen/3.4.phaseVar.slurm $refnam

