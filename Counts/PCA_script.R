# pca

cpm_nozero <- cpm[as.logical(rowSums(cpm != 0)), ]
cpmdf <- t(cpm_nozero)
cpmdf <- as.data.frame(cpmdf)

pca <- prcomp(cpmdf, center = TRUE, scale. = TRUE)
summary(pca)

scores = as.data.frame(pca$x)
scores <- cbind(scores,meta)

library(ggplot2)

ggplot(data = scores[1:24,], aes(x = PC1, y = PC2, color = Diff_batch, shape = Experiment)) + geom_point(size=5)


