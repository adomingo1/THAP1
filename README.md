# THAP1
## QC and alignment

### merge fastqs, and do fastQC

```
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


for file in `ls *.fastq.gz`; do #in /merged_fastqs
bsub -q normal -sla miket_sc -o /data/talkowski/broadIncoming/HL3WWDSXX_reDemultiplex/merged_fastqs/THAP1/fastQC/logs/${file}_fastQC.out -e /data/talkowski/broadIncoming/HL3WWDSXX_reDemultiplex/merged_fastqs/THAP1/fastQC/logs/${file}_fastQC.err -J ${file} "/PHShome/ry077/downloads/FastQC/fastqc ${file} -o /data/talkowski/broadIncoming/HL3WWDSXX_reDemultiplex/merged_fastqs/THAP1/fastQC"
done


source activate py3
multiqc . #in /fastQC
```

### trimming

```
cd /data/talkowski/Samples/THAP1/
mkdir trimmed

cd trimmed
sh ../scripts/Trimmomatic.sh
```

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

### fastqc post-trimming 

```
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
```

### alignment

```
mkdir -p THAP1/alignments
sh scripts/STAR_Alignment.sh
```

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

### post-alignment QC (BAMQC)

```
ls -1 alignments/*/*.Aligned.out.bam | sed "s?^?`pwd`?g" | awk -F"/" '{var=$NF;gsub(".Aligned.out.bam","",var); print $0,var}' OFS="\t" > THAP1.bam.list

sh scripts/bamsummaries.sh THAP1
```

```
#!/bin/bash

source activate py2

module load python/2.7.3
module load libssl/1.0.2

name=$1
DIR=`pwd`
scriptdir="/data/talkowski/Samples/PostMortem/scripts"
analysisfolder=${DIR}"/BAMQC/RNAQC"
mkdir -p $analysisfolder
referencefolder="/data/talkowski/tools/ref/RNA-Seq/human/ref_components/GRCh37.75"


python $scriptdir/multibamsummary.py -sp $scriptdir -af $analysisfolder -of $name -at rna -rf $referencefolder/Homo_sapiens.GRCh37.75.dna.primary_assembly.ercc.reordered.fa -G $referencefolder/Homo_sapiens.GRCh37.75.protein_coding -st fr-firststrand -f ${name}.bam.list -on ${name}.Summaries.txt -sj -sq big-multi
```

### getting counts

```
for file in `ls -1 alignments/*/*ReadsPerGene.out.tab`; do \
    IDtemp=${file%.ReadsPerGene.out.tab}
	ID=${IDtemp##*/}
    echo $ID
    cat $file | tail -n +5 | cut -f4 > counts/$ID.count
done



tail -n +5 /data/talkowski/Samples/THAP1/alignments/S21wt_6/S21wt_6.ReadsPerGene.out.tab | cut -f1 > geneids.txt #in counts

head geneids.txt

paste geneids.txt *.count > tmp.out
ls -1 *.count > samples.txt
sed -i -e 's/.count//gi' samples.txt
cat samples.txt | cut -f1 | paste -s > header.txt
cat header.txt tmp.out > all_counts.txt

```

### samtools to QC genotypes

```
mkdir -p snps/sorted
cd snps/sorted
cp ../../alignments/*/*.Aligned.out.rg.srtd.bam .
cp ../../alignments/*/*.Aligned.out.rg.srtd.bai .


for file in `ls -1 *.Aligned.out.rg.srtd.bam`; do
echo $file
samtools mpileup -g -t DP -r 8:42,691,816-42,698,467 -f /data/talkowski/tools/ref/RNA-Seq/human/ref_components/GRCh37.75/Homo_sapiens.GRCh37.75.dna.primary_assembly.ercc.reordered.fa $file | bcftools call -cv > /data/talkowski/Samples/THAP1/snps/$file.samtools.raw.bcf
```




