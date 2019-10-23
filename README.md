# THAP1
## QC and Alignment

### merge fastqs from different lanes, and do fastQC

cd /data/talkowski/broadIncoming/HL3WWDSXX_reDemultiplex/merged_fastqs/THAP1

while read sample file1 file2; do
echo ${sample} >> catlog
echo ${file1} >> catlog
test -f ../../${file1}
echo $? >> catlog
echo ${file2} >> catlog
test -f ../../${file2}
echo $? >> catlog
cat ../../${file1} ../../${file2} > ${sample}.fastq.gz
done < catfile

mkdir ../fastQC
cd ../fastQC
mkdir logs

### in directory merged_fastqs (note: use FastQC v0.11.7 from Rachita)

for file in `ls *.fastq.gz`; do
bsub -q normal -sla miket_sc -o /data/talkowski/broadIncoming/HL3WWDSXX_reDemultiplex/merged_fastqs/THAP1/fastQC/logs/${file}_fastQC.out -e /data/talkowski/broadIncoming/HL3WWDSXX_reDemultiplex/merged_fastqs/THAP1/fastQC/logs/${file}_fastQC.err -J ${file} "/PHShome/ry077/downloads/FastQC/fastqc ${file} -o /data/talkowski/broadIncoming/HL3WWDSXX_reDemultiplex/merged_fastqs/THAP1/fastQC"
done``

### in fastQC directory

source activate py3
multiqc .

### trimming (in THAP1 working directory)

cd /data/talkowski/Samples/THAP1/
mkdir trimmed

cd trimmed
sh ../scripts/Trimmomatic.sh

```
#!/bin/bash

# script for trimming (modified from Rachita's script from /data/talkowski/Samples/PostMortem/scripts/Trimmomatic.sh
# run in parent of raw_data

DIR=`pwd`
DATADIR=$DIR/raw_data
WORKDIR=$DIR/trimmed
mkdir -p $WORKDIR/logs

cd $DATADIR
for file in `ls *.R1.fastq.gz`;
do
        filename1="${file##*/}"    
	filename2=${filename1/R1./R2.}
	SN=${filename1%.R1.fastq.gz}
	echo $SN, $filename1 $filename2
        mkdir -p $WORKDIR/${SN}

        bsub -q big -sla miket_sc -o $WORKDIR/logs/report_$SN.out -e $WORKDIR/logs/report_$SN.err -J ${SN} "java -jar /PHShome/ry077/bin/trimmomatic-0.36.jar PE -phred33 $filename1 $filename2 $WORKDIR/${SN}/${SN}.R1.fastq.gz $WORKDIR/${SN}/${SN}.R1.unpaired.fastq.gz $WORKDIR/${SN}/${SN}.R2.fastq.gz $WORKDIR/${SN}/${SN}.R2.unpaired.fastq.gz ILLUMINACLIP:/data/talkowski/Samples/THAP1/scripts/Illumina_adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:80"
done
```

### fastqc post trimming (run in THAP1/trimmed/)

mkdir fastQC
mkdir -p fastQC/logs

for file in `ls */*.R1.fastq.gz`; do
IDtemp=${file%.R1.fastq.gz}
ID=${IDtemp##*/}
echo ${ID}
bsub -R 'hname!=cmu061 && hname!=cmu007 && hname!=cmu066' -q normal -sla miket_sc -o /data/talkowski/Samples/THAP1/trimmed/fastQC/logs/${ID}.R1.fastQC.out -e /data/talkowski/Samples/THAP1/trimmed/fastQC/logs/${ID}.R1.fastQC.err -J ${ID}.R1 "/PHShome/ry077/downloads/FastQC/fastqc ${file} -o /data/talkowski/Samples/THAP1/trimmed/fastQC"
done

for file in `ls */*.R2.fastq.gz`; do
IDtemp=${file%.R2.fastq.gz}
ID=${IDtemp##*/}
echo ${ID}
bsub -R 'hname!=cmu061 && hname!=cmu007 && hname!=cmu066' -q normal -sla miket_sc -o /data/talkowski/Samples/THAP1/trimmed/fastQC/logs/${ID}.R2.fastQC.out -e /data/talkowski/Samples/THAP1/trimmed/fastQC/logs/${ID}.R2.fastQC.err -J ${ID}.R2 "/PHShome/ry077/downloads/FastQC/fastqc ${file} -o /data/talkowski/Samples/THAP1/trimmed/fastQC"
done

### alignment

mkdir -p THAP1/alignments
sh scripts/STAR_Alignment.sh

```
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
```

### getting counts

tail -n +5 C54wt_1.ReadsPerGene.out.tab | cut -f1,2 > C54wt_1_NOTRIM.ReadsPerGene.out.tab.counts
