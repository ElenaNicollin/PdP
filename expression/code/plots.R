# ---------------- Packages Installation ----------------

print("Charging libraries")
library(DESeq2)
library(argparse)
library(GenomicAlignments)
library(GenomicFeatures)
library(ggplot2)
library(BiocParallel)
library(Rsamtools)
library(FactoMineR)
library(pheatmap)
library(AnnotationDbi)
library(org.Hs.eg.db)
library(gplots)
library(RColorBrewer)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(pheatmap)
library(EnhancedVolcano)

# ---------------------- Functions ----------------------

createObject <- function(dir_BAM,gtf_file){
  data.dir <- dir_BAM
  bamfiles <- list.files(path = data.dir, pattern = ".bam$",
                         all.files = TRUE, full.names = TRUE)
  gtf.file = gtf_file
  txDB <- makeTxDbFromGFF(gtf.file, format= "gtf")
  
  
  genes <- exonsBy(txDB, by="gene")
  register(MulticoreParam(2))
  se = summarizeOverlaps(features=genes,
                         reads=bamfiles, mode="Union",
                         singleEnd=FALSE, ignore.strand=TRUE)
  return(se)
}

boxplots <- function(se,output){
  #Plot the raw read count distribution per sample
  #Plot the normalized read count distribution per sample
  raw.counts <- assays(se)@listData$count
  colnames(raw.counts) <- sub(".bam","",colnames(raw.counts))
  #save plots as PDF
  pdf(file=output)
  par(mfrow=c(1,3))
  plot1 = boxplot(log2(raw.counts+1), main="log2 transformed raw counts",
                  ylab="log2(raw counts)")
  size.factors <- estimateSizeFactorsForMatrix(raw.counts)
  norm.counts <- t(t(raw.counts) / size.factors)
  norm.counts <- log2(norm.counts+1)
  plot2 = boxplot(log2(raw.counts+1), main="log2 transformed raw counts",
                  ylab="log2(raw counts)")
  plot3 = boxplot(norm.counts, main="log2 transformed normalized counts",
                  ylab="log2(normalized count)")
  dev.off()
  return(norm.counts)
}


createCountData <-function(countData, file_sample, condition){
  countData = assay(countData)
  colnames(countData) <- sub(".bam","",colnames(countData))
  colData <- read.csv(file, sep=";", row.names = 1)
  if(all(colnames(countData) %in% rownames(colData))){
    if(all(colnames(countData) == rownames(colData))){
      #colData[,condition] <- as.factor(colData[,condition])
      countData <- countData[,rownames(colData)]
      dds <- DESeqDataSetFromMatrix(countData = countData,
                                    colData = colData,
                                    design= condition)
      keep <- rowSums(counts(dds)) >= 10
      dds <- dds[keep,]
      dds <- DESeq(dds)
      res <- results(dds)
      df<-as.data.frame(res)
      signs.df = as.data.frame(res)
      signs.df$symbol = mapIds(x = org.Hs.eg.db, 
                               keys = rownames(signs.df), 
                               "ENSEMBL", 
                               "SYMBOL",
                               fuzzy = TRUE,
                               multiVals = first)
      return(list(dds,signs.df))
    }
  }
}

makeMAplot <- function(df,output){
  pdf(file=output)
  plotMA(df)
  plotDispEsts(df)
  dev.off()
}

transformation <- function(df){
  vsd <-varianceStabilizingTransformation(df, blind = TRUE, fitType = "parametric")
  return(vsd)
}

makePCA <- function(df,condition,output){
  pdf(file=output)
  p= plotPCA(df,condition)
  dev.off()
  return(p)
}

pheatmaplot <- function(vsd,df,output){
  pdf(file=output)
  mat <- assay(vsd)[head(order(df$padj),30),]
  mat <- mat - rowMeans(mat)
  dm <- as.data.frame(colData(vsd))
  p = pheatmap(mat,annotation_col=dm, 
               breaks = seq(-12,12,0.24),
               color=colorRampPalette(c("navy","navy",colours()[121],
                                        "white","red","firebrick","firebrick"))(100),
               cutree_cols = 3,
               cutree_rows = 5)
  dev.off()
  return(p)
  
}

heatmaplot <- function(dds,output){
  pdf(file = output)
  rld <- rlog(dds)
  head(assay(rld))
  sampleDists <- dist( t( assay(rld) ) )
  sampleDistMatrix <- as.matrix( sampleDists )
  colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
  hc <- hclust(sampleDists)
  p= heatmap.2( sampleDistMatrix, Rowv=as.dendrogram(hc),
                symm=TRUE, trace="none", col=colors,
                margins=c(2,10), labCol=FALSE )
  dev.off()
  return(p)
}

makeVocanoPlot1 <- function(data){
  pdf(file='/home/OutputFiles/plots/volcano_plot.pdf')
  p1 <- ggplot(data=data, aes(log2FoldChange, -log10(pvalue))) +  
    geom_point(size = 2/5) +
    xlab(expression("log"[2]*"FC")) + 
    ylab(expression("-log"[10]*"FDR"))
  return(p1)
  dev.off()
}

makeVocanoPlot2 <- function(data){
  pdf(file='/home/OutputFiles/plots/Volcano_Plot2.pdf')
  data$diffexpressed <- "NO"
  data$diffexpressed[data$log2FoldChange > 0.6 & data$pvalue < 0.05] <- "UP"
  data$diffexpressed[data$log2FoldChange < 0.6 & data$pvalue < 0.05] <- "DOWN"
  data$delabel = rownames(data)
  p = ggplot(data=data, aes(x=log2FoldChange, y=-log10(pvalue), col=diffexpressed, label= delabel)) +
    geom_point() + 
    theme_minimal() +
    geom_text_repel() +
    geom_label_repel()+     
    scale_color_manual(values=c("blue", "black", "red")) +
    geom_vline(xintercept=c(-0.6, 0.6), col="red") +
    geom_hline(yintercept=-log10(0.05), col="red")
  theme (text=element_text(size=20))
  return(p)
  dev.off()
}

makeVocanoPlot3 <- function(data){  
  pdf(file='/home/OutputFiles/plots/Volcano_Plot3.pdf')
  data$diffexpressed <- "NO"
  data$diffexpressed[data$log2FoldChange > 0.6 & data$pvalue < 0.05] <- "UP"
  data$diffexpressed[data$log2FoldChange < 0.6 & data$pvalue < 0.05] <- "DOWN"
  data$delabel = rownames(data)
  p = ggplot (data = data, aes (x= log2FoldChange, y = -log10 (pvalue), col= diffexpressed, label= delabel )) +
    geom_point()+
    theme_minimal()+
    geom_text_repel()+
    scale_color_manual (values= c('blue', 'black', 'red'))+
    theme (text=element_text(size = 20))
  return(p)
  dev.off()
}


makeEnhacedVolcano <- function(data){
  pdf(file='/home/OutputFiles/plots/Enhaced_Volcanoplot.pdf')
  p = EnhancedVolcano(data,
                      lab = rownames(data) ,
                      x = 'log2FoldChange',
                      y = 'pvalue')
  return(p)
  dev.off()
}


# ---------------- Parsing arguments --------------------

parser <- ArgumentParser(description= 'Generate plots.')
parser$add_argument('--genome', '-a', help= 'Input genome in gtf format')
parser$add_argument('--pheno', '-b', help= 'CSV file containing pheno data')
parser$add_argument('--gtf', '-c', help= 'Directory containing GTF files')
parser$add_argument('--bam', '-d', help= 'Directory containing BAM files')
parser$add_argument('--box', '-e', help= 'PDF file to output with boxplots')
parser$add_argument('--hm', '-f', help= 'PDF file to output with heatmaps')
parser$add_argument('--ma', '-g', help= 'PDF file to output with MA plots')
parser$add_argument('--pca', '-h', help= 'PDF file to output with PCA')
parser$add_argument('--pm', '-i', help= 'PDF file to output with pheatmaps')

xargs<- parser$parse_args()



#------------------------- MAIN -------------------------

GTF_dir <- xargs$gtf
se = createObject(xargs$bam, xargs$genome)
head(assay(se))
norm.object = boxplots(se, xargs$box)
norm.object
file <- xargs$pheno
countData = createCountData(se,file, ~naevus)
head(countData[[1]])
# variance stabilizing transformation
vsd = transformation(countData[[1]])
# Plot of PCA
makePCA(vsd,"cheveux", xargs$pca)
makeMAplot(countData[[1]], xargs$ma)
#Heatmaps
pheatmaplot(vsd,countData[[2]], xargs$pm)
heatmaplot(countData[[1]], xargs$hm)
#Volcanoplots
makeVocanoPlot1(countData[[2]])
makeVocanoPlot2(countData[[2]])
makeVocanoPlot3(countData[[2]])
makeEnhacedVolcano(countData[[2]])
