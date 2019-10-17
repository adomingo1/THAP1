#!/bin/bash

# script for trimming (modified from Rachita's script from /data/talkowski/Samples/PostMortem/scripts/Trimmomatic.sh)
# run in raw_data/

DIR=`pwd`
WORKDIR=$DIR/trimmed
mkdir -p $DIR/trimmed/logs

for file in `ls */*.R1.fastq.gz`

do
    filename1="${file##*/}"    
	filename2=${filename1/R1./R2.}
	SN=${filename1%.R1.fastq.gz}
	echo $SN, $filename1 $filename2
    mkdir -p $WORKDIR/${SN}_trimmed

    bsub -q big -sla miket_sc -o $DIR/trimmed/logs/report_$SN.out -e $DIR/trimmed/logs/report_$SN.err -J ${SN} "java -jar /PHShome/ry077/bin/trimmomatic-0.36.jar PE -phred33 $filename1 $filename2 $WORKDIR/${SN}_trimmed/${SN}.R1.fastq.gz $WORKDIR/${SN}_trimmed/${SN}.R1.unpaired.fastq.gz $WORKDIR/${SN}_trimmed/${SN}.R2.fastq.gz $WORKDIR/${SN}_trimmed/${SN}.R2.unpaired.fastq.gz ILLUMINACLIP:/apps/lab/miket/Trimmomatic-0.36/adapters/TruSeq3-PE-miket.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:80"

done