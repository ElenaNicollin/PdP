# ---------------- BiocManager Installation ----------------

install.packages("argparse", repos = "http://cran.us.r-project.org")
install.packages("BiocManager", repos = "http://cran.us.r-project.org")
BiocManager::install("GenomicAlignments")
BiocManager::install("GenomicFeatures")
BiocManager::install("DESeq2")
BiocManager::install("org.Hs.eg.db")
BiocManager::install("AnnotationDbi")
BiocManager::install("EnhancedVolcano")