## variables ***********************************************************************************************************
# while getopts ":r:n:f:" opt; do
#   case ${opt} in
#     r ) readgp=$OPTARG ;;
#     n ) refnam=$OPTARG ;;
#     f ) fasref=$OPTARG ;;
#     \? )
#       echo "Usage: cmd [-h] [-t]"
#       echo "Invalid option: $OPTARG" 1>&2
#       ;;
#     : ) echo "Invalid option: $OPTARG requires an argument" 1>&2 ;;
#   esac
# done
# shift $((OPTIND -1))
# echo $readgp
# echo $refnam
# echo $fasref


# readgp="readgroups.txt"
# refnam="hmelv25"
# fasref="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/Heliconius_melpomene_melpomene_Hmel2.5.scaffolds.fa"
# export readgp=$readgp
# export fasref=$fasref
# export refnam=$refnam
# readgp="readgroups.txt"
# refnam="heradem"
# fasref="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/heradem/Heliconius_erato_demophoon_v1_-_scaffolds.fa"
# export readgp=$readgp
# export fasref=$fasref
# export refnam=$refnam
readgp="readgroups.2.txt"
refnam="driulv1"
fasref="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/driulv1/Diul.assembly.v1.1.fasta"
export readgp=$readgp
export fasref=$fasref
export refnam=$refnam



## Create all Directories **********************************************************************************************
mkdir code
mkdir 0.2.cutadapt
mkdir 1.0.bwa
mkdir 1.0.bwa/sam
mkdir 1.1.sort
mkdir 1.2.rmdup
mkdir 1.2.rmdup/wincov
mkdir 1.3.realign



## Trim adapters - Cutadapt ********************************************************************************************
# cutadapt/trimmomatic
# cat readgroups.txt | cut -f2 | xargs -n 1 sh -c 'sbatch /n/home12/fseixas/code/heliconius_seixas/wgs_workflow/scripts/0.1.cutadapt.slurm $0'
cat ${readgp} | cut -f2 | xargs -n 1 sh -c 'sbatch /n/home12/fseixas/code/heliconius_seixas/wgs_workflow/scripts/0.1.trimmomatic.slurm $0'



## map data - BWA-mem **************************************************************************************************
# create read group lines
rm code/readgroups2bwa.$refnam.txt
cat ${readgp} | uniq | xargs -n 5 sh -c ' echo $1" -RAAA@RGXXXSM:"$0"XXXID:"$1"XXXPU:"$2"XXXPL:"$3"XXXLB:"$4"AAA" >> code/readgroups2bwa.${refnam}.txt'
cat code/readgroups2bwa.$refnam.txt
# create bwa commands
rm code/bwa.commands.$refnam.sh
cat code/readgroups2bwa.$refnam.txt | xargs -n 2 sh -c '
    echo /n/home12/fseixas/software/bwa.0.7.17/bwa mem -M -t 16 $1 $fasref \
    0.2.cutadapt/$0.r1.fastq.gz \
    0.2.cutadapt/$0.r2.fastq.gz \> 1.0.bwa/$0.$refnam.sam >> code/bwa.commands.$refnam.sh'
# transform to correct format
sed -i 's/AAA/ \"/' code/bwa.commands.$refnam.sh
sed -i 's/AAA/\"/' code/bwa.commands.$refnam.sh
sed -i 's/XXX/\\t/g' code/bwa.commands.$refnam.sh
## launch BWA - map to reference ----
rm code/bwa.launch.$refnam.1??.sh
split -l 1 -a 2 --numeric-suffixes=10 --additional-suffix .sh code/bwa.commands.$refnam.sh code/bwa.launch.$refnam.1
#las=`wc -l code/bwa.commands.$refnam.sh | cut -d' ' -f1`
sbatch --array=110-115%6 ~/code/heliconius_seixas/wgs_workflow/scripts/1.0.bwa.slurm $refnam



## Process BAM files (sort and sam2bam) ********************************************************************************
# convert to bam and sort -------
cut -f2 ${readgp} | xargs -n 1 sh -c 'sbatch ~/code/heliconius_seixas/wgs_workflow/scripts/1.1.process_bam.slurm $0.$refnam'



## Remove duplicates ***************************************************************************************************
# cut -f2 $readgp | xargs -n 1 sh -c 'sbatch /n/home12/fseixas/code/heliconius_seixas/wgs_workflow/scripts/1.2.rmdup.picard.slurm $0 $refnam'
# create file with rmdup commands 
rm x1??.sh
rm rmdup_commands.file
for RG in `cut -f 1 $readgp | sort | uniq`; do
    awk -v readg="$RG" '{if ($1 == readg) print $2}' $readgp | uniq > $RG.list
    printf "%s" "/n/home12/fseixas/software/sambamba-1.0.1-linux-amd64-static markdup -r -t 4 -p --tmpdir tmp.$RG " >> rmdup_commands.file
    for line in `cat $RG.list`; do 
        file=`ls 1.1.sort/*.bam | grep $line | grep $refnam`;
        printf "%s " $file >> rmdup_commands.file
    done 
    printf "1.2.rmdup/$RG.$refnam.rmdup.bam\n" >> rmdup_commands.file
    rm $RG.list
done 
# prepare slurm files
wc -l rmdup_commands.file
split -l 1 -a 3 --numeric-suffixes=110 --additional-suffix .sh rmdup_commands.file
rm rmdup_commands.file
# run rmdup
sbatch --array=110-115%6 /n/home12/fseixas/code/heliconius_seixas/wgs_workflow/scripts/1.2.rmdup.slurm



## Coverage - sliding windows ******************************************************************************************
cat readgroups.txt | cut -f1 | uniq | xargs -n 1 sh -c '
    sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/0.dataTreatment/mapANDsnpcall/coverage.wins.slurm $0 $refnam
'



## Realign *************************************************************************************************************
# for prefix in ` cat ${readgp} | cut -f1 | uniq | egrep "ros|bel|mal|ecu" `; do 
for prefix in ` cat ${readgp} | cut -f1 | sort | uniq `; do 
    echo $prefix;
    sbatch ~/code/heliconius_seixas/wgs_workflow/scripts/1.3.realign.slurm ${prefix} ${fasref} ${refnam};
done


readgp="readgroups.2.txt"
refnam="driulv1"
fasref="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/driulv1/Diul.assembly.v1.1.fasta"
export readgp=$readgp
export fasref=$fasref
export refnam=$refnam


cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/driulv1/driulv1.scaffolds.txt | xargs -n 1 sh -c '
    echo $0;
    sbatch ~/code/heliconius_seixas/wgs_workflow/scripts/1.3.realign.slurm $0.Diul.alc.Sur.099 ${fasref} ${refnam}
    '


java -Xmx4g -jar ~/software/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar

java -jar /n/home12/fseixas/software/gatk-4.5.0.0/gatk-package-4.5.0.0-local.jar -Xmx4g -T HaplotypeCaller  \
   -R ${fasref} \
   -I 1.2.rmdup/Diul.alc.FGu.025.driulv1.rmdup.bam \
   -O Diul.alc.FGu.025.driulv1.g.vcf.gz \
   -ERC GVCF

