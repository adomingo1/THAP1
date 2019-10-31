# to make plots for individual genes

allcounts <- read.delim("all_counts.txt",header = TRUE,sep = "\t")
cpm <- 1e6*t(t(allcounts)/colSums(allcounts))

barplot(cpm[rownames(cpm)=="ENSG00000131931",],las=2,main="ENSG00000131931")

meta <- read.csv("Metadata.csv", header = TRUE, sep = ",", row.names = 1)
all(colnames(cpm) %in% rownames(meta))
all(colnames(cpm) == rownames(meta))

THAP1 <- (cpm[rownames(cpm)=="ENSG00000131931",])
THAP1meta<-cbind(meta,THAP1)

library(ggplot2)
barpl <- ggplot(THAP1meta, aes(fill=Genotype2, y=THAP1, x=rownames(THAP1meta))) + 
  geom_bar(position="dodge", stat="identity") + theme(axis.text.x = element_text(angle = 90))
barpl + ggtitle("THAP1") + xlab("samples") + ylab("cpm") + theme(plot.title = element_text(hjust = 0.5))

ggplot(THAP1meta, aes(x=Genotype2, y=THAP1, fill=Genotype2)) + 
  geom_boxplot() +
  facet_wrap(~Experiment, scales="free") + 
  ggtitle("THAP1") + theme(plot.title = element_text(hjust = 0.5)) +
  xlab("") + ylab("cpm") + theme(legend.position = "none") +
  theme(text = element_text(size = 15))

RRM1 <- (cpm[rownames(cpm)=="ENSG00000167325",])
RRM1meta<-cbind(meta,RRM1)

ggplot(RRM1meta, aes(x=Genotype2, y=RRM1, fill=Genotype2)) + 
  geom_boxplot() +
  facet_wrap(~Experiment, scales="free") + 
  ggtitle("RRM1") + theme(plot.title = element_text(hjust = 0.5)) +
  xlab("") + ylab("cpm") + theme(legend.position = "none") +
  theme(text = element_text(size = 15))

TOR1A <- (cpm[rownames(cpm)=="ENSG00000136827",])
TOR1Ameta<-cbind(meta,TOR1A)

ggplot(TOR1Ameta, aes(x=Genotype2, y=TOR1A, fill=Genotype2)) + 
  geom_boxplot() +
  facet_wrap(~Experiment, scales="free") + 
  ggtitle("TOR1A") + theme(plot.title = element_text(hjust = 0.5)) +
  xlab("") + ylab("cpm") + theme(legend.position = "none") +
  theme(text = element_text(size = 15))
