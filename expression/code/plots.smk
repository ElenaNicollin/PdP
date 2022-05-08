import sys
sys.path.append('/home/Utils/')
from pipeline import wildcard

configfile: "/home/Utils/config.yaml"

rule all:
    input:
        expand("/home/OutputFiles/plots/{ID}.pdf", ID=wildcard('/home/OutputFiles/plots/', ['.pdf'])[0])

rule plots:
    input:
        genome=config["ref_gtf"],
        pheno="/home/Data/pheno_data.csv",
        gtf="/home/OutputFiles/GTF/",
        bam="/home/BAM/",
    output:
        boxplots="/home/OutputFiles/plots/CountData_boxplots.pdf",
        heatmap="/home/OutputFiles/plots/heatmap_plot.pdf",
        ma="/home/OutputFiles/plots/MAplots_DispEstsplots.pdf",
        pca="/home/OutputFiles/plots/PCA_Condition.pdf",
        pheatmap="/home/OutputFiles/plots/Pheatmap.pdf",
    shell:
        "Rscript /home/Utils/plots.R \
        --genome {input.genome} \
        --pheno {input.pheno} \
        --gtf {input.gtf} \
        --bam {input.bam} \
        --box {output.boxplots} \
        --hm {output.heatmap} \
        --ma {output.ma} \
        --pca {output.pca} \
        --pm {output.pheatmap}"
