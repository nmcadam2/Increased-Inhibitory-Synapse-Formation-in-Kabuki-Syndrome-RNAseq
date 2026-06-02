#Originally prepared by the Patzke Lab, and Sheri S. Sanders. Modified by Neil McAdams to allow custom x limits on axis and custom titles.

fancy_volcano_plot <- function(data, pcut, fccut, xlim, tit, input = "deseq2") {
library(ggplot2)
library(readr)
library(dplyr)
library(ggrepel)


significant_genes = na.omit(data)
significant_genes = significant_genes[significant_genes$padj <= pcut,]
significant_genes = significant_genes[(significant_genes$log2FoldChange > fccut | significant_genes$log2FoldChange < -fccut),]

if (!"gene" %in% colnames(data)) {
  data$gene = rownames(data)
}

# Create the volcano plot with specific colors and labels 
#if edgeR
if (input == "edger") {
volcano_plot <- ggplot(data, aes(x = logFC, y = -log10(FDR))) +
  geom_point(aes(color = factor(ifelse(FDR < 0.05 & logFC >= 2, "Upregulated",
                                       ifelse(FDR < pcut & logFC <= -fccut, "Downregulated",
                                              "Not Significant")))), alpha = 0.5) +
  scale_color_manual(values = c("Upregulated" = rgb(1,0,0,0.5),
                                "Downregulated" = rgb(0.53,0.81,0.98,0.5),
                                "Not Significant" = "grey"),
                     name = "Expression Change") +
  geom_text_repel(data = significant_genes, aes(label = gene),
                  size = 3,
                  max.overlaps = 20) +
  labs(title = "Volcano Plot",
       x = "Log2 Fold Change",
       y = "-Log10 Adjusted P-value") +
  theme_minimal() +
  theme(legend.position = "top",
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12)) +
  geom_vline(xintercept = c(-fccut, fcut), linetype = "dashed", color = "black") +
  geom_hline(yintercept = -log10(pcut), linetype = "dashed", color = "black") +
  theme(panel.grid.major = element_line(color = "grey80"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_line(color = "grey80", linetype = "dashed"),
        panel.grid.major.y = element_line(color = "grey80", linetype = "dashed"))
}


#if DESeq2
if (input == "deseq2") {
significant_genes = na.omit(data)
significant_genes = significant_genes[significant_genes$padj <= pcut,]
significant_genes = significant_genes[(significant_genes$log2FoldChange > fccut | significant_genes$log2FoldChange < -fccut),]

volcano_plot <- ggplot(data, aes(x = log2FoldChange, y = -log10(padj))) +
  geom_point(aes(color = factor(ifelse(padj < pcut & log2FoldChange >= fccut, "Upregulated",
                                       ifelse(padj < pcut & log2FoldChange <= -fccut, "Downregulated",
                                              "Not Significant")))), alpha = 0.5) +
  coord_cartesian(xlim = c(-xlim, xlim))+
  scale_color_manual(values = c("Upregulated" = rgb(1,0,0,0.5),
                                "Downregulated" = rgb(0.53,0.81,0.98,0.5),
                                "Not Significant" = "grey"),
                     name = "Expression Change") +
  geom_text_repel(data = significant_genes, aes(label = gene),
                  size = 3,
                  max.overlaps = 20) +
  labs(title = tit,
       x = "Log2 Fold Change",
       y = "-Log10 Adjusted P-value") +
  theme_minimal() +
  theme(legend.position = "top",
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12)) +
  geom_vline(xintercept = c(-fccut, fccut), linetype = "dashed", color = "black") +
  geom_hline(yintercept = -log10(pcut), linetype = "dashed", color = "black") +
  theme(panel.grid.major = element_line(color = "grey80"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_line(color = "grey80", linetype = "dashed"),
        panel.grid.major.y = element_line(color = "grey80", linetype = "dashed"))
}

volcano_plot
}
