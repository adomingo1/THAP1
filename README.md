# THAP1

# QC and Alignment

# copy files to directory /data/talkowski/broadIncoming/HL3WWDSXX_reDemultiplex/merged_fastqs/THAP1, merge fastqs from different lanes, and do fastQC

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

# in directory merged_fastqs (note: use FastQC v0.11.7 from Rachita)

for file in `ls *.fastq.gz`; do
bsub -q normal -sla miket_sc -o /data/talkowski/broadIncoming/HL3WWDSXX_reDemultiplex/merged_fastqs/THAP1/fastQC/logs/${file}_fastQC.out -e /data/talkowski/broadIncoming/HL3WWDSXX_reDemultiplex/merged_fastqs/THAP1/fastQC/logs/${file}_fastQC.err -J ${file} "/PHShome/ry077/downloads/FastQC/fastqc ${file} -o /data/talkowski/broadIncoming/HL3WWDSXX_reDemultiplex/merged_fastqs/THAP1/fastQC"
done

# in fastQC directory

source activate py3
multiqc .

# copied files to /data/talkowski/Samples/THAP1/raw_data/

# alignment using STAR_Alignment.sh (run in parent of raw_data/)

# tried trimming before alignment (run in raw_data/trimmed)

# fastqc post trimming (run in raw_data/trimmed), then alignment using STAR_Alignment_trimmed.sh (run in trimmed/)

for file in `ls */*.{R1,R2}.fastq.gz`; do
bsub -q normal -sla miket_sc -o /data/talkowski/Samples/THAP1/raw_data/trimmed/fastQC/logs/${file}_fastQC.out -e /data/talkowski/Samples/THAP1/raw_data/trimmed/fastQC/logs/${file}_fastQC.err -J ${file} "/PHShome/ry077/downloads/FastQC/fastqc ${file} -o /data/talkowski/Samples/THAP1/raw_data/trimmed/fastQC"
done

# getting counts 

tail -n +5 C54wt_1.ReadsPerGene.out.tab | cut -f1,2 > C54wt_1_NOTRIM.ReadsPerGene.out.tab.counts
