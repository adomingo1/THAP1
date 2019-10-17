trim <- read.table("C54wt_1_TRIM.ReadsPerGene.out.tab.counts.txt")
colnames(trim)=c("Gene","Counts_Trimmed")

notrim <- read.table("C54wt_1_NOTRIM.ReadsPerGene.out.tab.counts.txt")
colnames(notrim)=c("Gene","Counts_NoTrim")

df <- merge(trim,notrim,by.x="Gene")
cor.test(df$Counts_Trimmed, df$Counts_NoTrim, method=c("pearson", "kendall", "spearman"))

library("ggpubr")
ggscatter(df, x = "Counts_Trimmed", y = "Counts_NoTrim", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Counts_Trimmed", ylab = "Counts_NoTrim")

# using only >10

library(dplyr)
trim_nonzero <- filter(trim,Counts_Trimmed>10)
notrim_nonzero <- filter(notrim,Counts_NoTrim>10)

df_nonzero <- merge(trim_nonzero,notrim_nonzero,by.x="Gene", all.y = TRUE)
df_nonzero[is.na(df_nonzero)] <- 0

ggscatter(df_nonzero, x = "Counts_Trimmed", y = "Counts_NoTrim", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Counts_Trimmed", ylab = "Counts_NoTrim")
