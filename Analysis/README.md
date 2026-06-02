# Analysis Scripts
This repository contains all analysis scripts downstream of alignment. Including:
1. Differential gene expression analysis in DESeq2.
2. Functional enrichment with ClusterProfiler.
3. rMATS analysis, filtering, and plotting.

The DESeq2 differential gene expression analysis is split by experiment 1 and 2. For experiment 1 there is additional code for plotting both experiments result comparison bar plots, and a third section for plotting deconvolution results. Functional enrichment is set up as a single script and parameters are altered as necessary for each experiment. The rMATS analysis script is in BASH and ran on a HPC cluster at the University of Notre Dame. The rMATS filtering and plotting script is in R and was ran locally on R studio.

The R scripts are provided as markdown documents as well as knitted html reports to provide the exact run parameters. All R analyses were performed in R 4.3.3 unless otherwise stated.
