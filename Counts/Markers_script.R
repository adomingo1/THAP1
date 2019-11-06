# to make heatmap using markers

# read features
read.csv("features.csv", header=TRUE, row.names=1) -> features
markers <- c(rownames(features))

# subset, maintaining order in markers
cpm[match(markers, rownames(cpm)), ] -> cpm_markers

# to make different annotation bars
meta_diff <- meta["Diff_batch"]
meta_Genotype2 <- meta["Genotype2"]
meta_Group <- meta["Group"]
meta_Experiment<- meta["Experiment"]
meta_3 <- meta[c("Genotype","Diff_batch")]

#heatmap
library(pheatmap)
library(gplots)
library(RColorBrewer)
nt = log2(cpm_markers+1) 
genes = rownames(cpm_markers)
samples = colnames(cpm_markers) 

samplesDists <- dist(t(nt))
genesDists <- as.dist(abs(cor(t(nt))))

heatColors <- colorRampPalette( rev(brewer.pal(11, "RdBu")) )(255)

colNames = samples
rowNames = features[genes,"names"]

pheatmap(nt, scale = "row",
         cluster_rows=FALSE,
         clustering_distance_rows=genesDists,
         clustering_distance_cols=samplesDists,
         col = heatColors,
         fontsize = 8,
         #main = fileName,
         annotation_col = meta_3,
         #annotation_colors = ann_colors,
         labels_row = rowNames,
         labels_col = colNames,
         display_numbers = FALSE,
         cellheight = 7)
        #filename = paste0(fileName,".pdf"))