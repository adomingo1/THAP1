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