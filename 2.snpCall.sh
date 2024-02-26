# ## load modules
# module load bcftools/1.5-fasrc02
# module load tabix/0.2.6-fasrc01
# module load plink/1.90-fasrc01


## Create directories **************************************************************************************************
mkdir 2.0.mpileup
mkdir 2.1.call
mkdir 2.2.filter
mkdir 2.2.filter/2.2.1.markfilter
mkdir 2.2.filter/2.2.2.passfilter
mkdir 2.2.filter/2.2.3.normfilter
mkdir 2.3.merge

## define variables

#/ hmevl25
# readgp="readgroups.txt"
# refnam="hmelv25"
# fasref="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/Heliconius_melpomene_melpomene_Hmel2.5.scaffolds.fa"
# scaffList="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt"
# smpsex="/n/mallet_lab/Lab/fseixas/1.projects/6.dryas/0.data/support/samples.sex"
# ploidy="/n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/0.data/support/ploidy/scaffolds.ploidy"

#/ dryas iulia
readgp="readgroups.2.txt"
refnam="driulv1"
fasref="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/driulv1/Diul.assembly.v1.1.fasta"
scaffList="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/driulv1/driulv1.scaffolds.txt"
smpsex="/n/mallet_lab/Lab/fseixas/1.projects/6.dryas/0.data/support/samples.sex"
ploidy="/n/mallet_lab/Lab/fseixas/1.projects/6.dryas/0.data/support/samples.ploidy"

#/ erato demophoon
# readgp="readgroups.txt"
# refnam="heradem"
# fasref="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/heradem/Heliconius_erato_demophoon_v1_-_scaffolds.fa"
# scaffList="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/heradem/heradem.scaffolds.txt"

export readgp=$readgp
export fasref=$fasref
export refnam=$refnam
export scaffList=$scaffList
export smpsex=$smpsex
export ploidy=$ploidy


## first create support files ===================================================
mkdir support
mkdir support/poplists

## define populations
for pop in `cut -d'.' -f1,2,3 ${readgp} | cut -d'_' -f1,2 | sort | uniq`; do 
    ls 1.3.realign/$pop*$refnam*bam > support/poplists/$pop.$refnam.list; 
done

## define sex (ploidy of the Z-chromosome)
for pop in `cut -d'.' -f1 ${readgp} | cut -d'_' -f1,2 | sort | uniq `; do
    export pop=$pop; echo $pop;
    grep $pop ${smpsex} > support/$pop.samples.sex;
done


# define pop calls
for pop in `cat ${readgp} | cut -f1 | sort | uniq`; do 
    ls 1.3.realign/$pop*$refnam*bam > support/poplists/$pop.$refnam.list;
done

## define sex (ploidy of the Z-chromosome)
for pop in `cat ${readgp} | cut -f1 | sort | uniq`; do 
    export pop=$pop; echo $pop;
    grep $pop ${smpsex} > support/sex/$pop.samples.sex;
done



## SNPcall | SAMTOOLS PIPELINE *****************************************************************************************

#/ 2.0 mpileup by population 
# for pop in `cut -f2 support/ind2popMap.txt | sort | uniq `; do
for pop in `cat ${readgp} | cut -f1 | sort | uniq `; do 
    export pop=$pop; echo $pop;
    sbatch ~/code/heliconius_seixas/wgs_workflow/scripts/2.0.mpileup.slurm $scaffList $pop $fasref $refnam;
done

#/ 2.1 call by population 
# call SNPs 
# for pop in `cut -f2 support/ind2popMap.txt | sort | uniq `; do
for pop in `cat ${readgp} | cut -f1 | sort | uniq `; do 
    export pop=$pop; echo $pop;
    sbatch ~/code/heliconius_seixas/wgs_workflow/scripts/2.1.call.slurm $scaffList $ploidy $pop $refnam 1Z 1W;
done

#/ 2.2 filter vcfs per population 
## filter data # include invariant sites GT="0/0" /// minDP >= 8 /// GT >= 20 /// QUAL >= 20 /// MQ >= 20
# for pop in `cut -f2 support/ind2popMap.txt | sort | uniq `; do
for pop in `cat ${readgp} | cut -f1 | sort | uniq | egrep "Diul.alc.Per.n01" `; do 
    echo $pop;
    sbatch ~/code/heliconius_seixas/wgs_workflow/scripts/2.2.filter.slurm $scaffList $pop $fasref $refnam;
done

#/ 2.3. merge sample sets 
#/ merge
sbatch ~/code/heliconius_seixas/wgs_workflow/scripts/2.3.merge.slurm ${scaffList} ${refnam}
#/ simplify
sbatch ~/code/heliconius_seixas/wgs_workflow/scripts/2.4.simplify-vcf.slurm ${scaffList} ${refnam} 1Z 1W
sbatch ~/code/heliconius_seixas/wgs_workflow/scripts/2.4.simplify-vcf.slurm ${scaffList} ${refnam} Herato2101 none


