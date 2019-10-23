#!/bin/bash

# script for STAR Alignment (modified from Rachita's script from /data/talkowski/Samples/PostMortem/scripts/Alignment.sh)
# run in parent of /trimmed/

DIR=`pwd`
DATADIR=$DIR/trimmed
WORKDIR=$DIR/alignments

mkdir -p $WORKDIR/logs

module load star/2.5.3

cd $DATADIR
for file in `ls */*.R1.fastq.gz`
do

IDtemp=${file%.R1.fastq.gz}
ID=${IDtemp##*/}
mkdir -p $WORKDIR/$ID

echo $WORKDIR
echo $ID

bsub -sla miket_sc -q big-multi -n 8 -M 50000 -J ${ID} \
      -o $WORKDIR/logs/${ID}.out -e $WORKDIR/logs/${ID}.err \
      "STAR --runThreadN 8 \
      --genomeDir /data/talkowski/Samples/PostMortem/data/ref/STAR \
      --twopassMode Basic \
      --outSAMunmapped Within \
      --outFilterMultimapNmax 1 \
      --outFilterMismatchNoverLmax 0.1 \
      --outSAMtype BAM Unsorted \
      --readFilesCommand zcat \
      --alignEndsType Local \
      --alignIntronMin 21 \
      --alignIntronMax 0 \
      --quantMode GeneCounts \
      --outFileNamePrefix $WORKDIR/${ID}/${ID}. \
      --readFilesIn $DATADIR/${ID}/${ID}.R1.fastq.gz $DATADIR/${ID}/${ID}.R2.fastq.gz"
    
done