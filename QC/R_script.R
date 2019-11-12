# QC plots from BAMQC output

## parsed output file divided into different files based on content/tool

GPRNASeqQC <- read.csv("GPRNASeqQC.csv", sep=",")
Metadata <- read.csv("Metadata.csv", sep=",")

library(ggplot2)
library(RColorBrewer)

GPRNAmeta<-merge(Metadata,GPRNASeqQC)

ggplot(GPRNAmeta, aes(fill=Genotype2, y=Mean.Per.Base.Cov., x=Sample)) + 
  geom_bar(position="dodge", stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust=1)) + scale_fill_brewer(palette="Paired") + 
  ggtitle("Mean Per Base Coverage") + xlab("samples") + ylab("coverage") + theme(plot.title = element_text(hjust = 0.5))

DupMetrics <- read.csv("DupMetrics.csv", sep=",")
Dupmeta<-merge(Metadata,DupMetrics)

ggplot(Dupmeta, aes(fill=Genotype2, y=PERCENT_DUPLICATION, x=Sample)) + 
  geom_bar(position="dodge", stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust=1)) + scale_fill_brewer(palette="Paired") + 
  ggtitle("Duplication Rate") + xlab("samples") + ylab("percent duplication") + theme(plot.title = element_text(hjust = 0.5))

InsertSize <- read.csv("InsertSize.csv", sep=",")
Insertmeta<-merge(Metadata,InsertSize)

ggplot(Insertmeta, aes(fill=Genotype2, y=MEAN_INSERT_SIZE, x=Sample)) + 
  geom_bar(position="dodge", stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust=1)) + scale_fill_brewer(palette="Paired") + 
  ggtitle("Mean Insert Size") + xlab("samples") + ylab("bp") + theme(plot.title = element_text(hjust = 0.5))

SummStats <- read.csv("SummStats.csv", sep=",")
SummStatsmeta<-merge(Metadata,SummStats)

ggplot(SummStatsmeta, aes(fill=Genotype2, y=numAlignments, x=Sample)) + 
  geom_bar(position="dodge", stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust=1)) + scale_fill_brewer(palette="Paired") + 
  ggtitle("Alignments") + xlab("samples") + ylab("count") + theme(plot.title = element_text(hjust = 0.5))

## PCA to investigate influence of high intergenic rate on clustering

PC <- read.csv("PC.csv", sep=",")
GPRNApc<-merge(GPRNAmeta,PC)

ggplot(data = GPRNApc, aes(x = PC1, y = PC2, color = Intergenic.Rate, shape = Genotype)) + geom_point(size=3)
