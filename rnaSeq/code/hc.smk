import sys
sys.path.append('/home/Utils/')
from pipeline import *

configfile: "/home/Rules/VariantCalling/HaplotypeCaller/config.yaml"

rule all:
    input:
        #expand("/home/OutputFiles/VCF/HaplotypeCaller/3-Final/{ID}.vcf.gz", ID=wildcard('/home/OutputFiles/BAM/6-BQSR/',['.bam'])[0])
        expand("/home/OutputFiles/GVCF/HaplotypeCaller/1-Intermediate/{ID}.vcf.gz", ID=wildcard('/home/OutputFiles/BAM/6-BQSR/',['.bam'])[0])

rule haplotype_caller:
    input:
        # single or list of bam files
        bam="/home/OutputFiles/BAM/6-BQSR/{sample}.bam",
        ref=config["ref"],
        known=config["known"]
    output:
        gvcf="/home/OutputFiles/GVCF/HaplotypeCaller/1-Intermediate/{sample}.vcf.gz"
    log:
        "/home/Log/20_HaplotypeCaller_{sample}.log"
    benchmark:
        "/home/Benchmark/20_HaplotypeCaller_{sample}.txt"
    params:
        extra=config["HaplotypeCaller_parameters"],  # optional
        java_opts=config["HaplotypeCaller_java_options"] # optional
    script:
        "/home/Utils/haplotypecaller.py"

#rule gatk_filter:
#    input:
#        vcf="/home/OutputFiles/VCF/HaplotypeCaller/1-Intermediate/{sample}.vcf.gz"
#        ref=config["ref"]
#    output:
#        vcf="/home/OutputFiles/VCF/HaplotypeCaller/2-Filtered/{sample}.vcf.gz"
#    log:
#        "/home/Log/21_VariantFiltration_{sample}.log"
#    benchmark:
#        "/home/Benchmark/21_VariantFiltration_{sample}.txt"
#    params:
#        filters=config["VariantFiltration_filters"],
#        extra=config["VariantFiltration_parameters"],  # optional arguments, see GATK docs
#        java_opts=config["VariantFiltration_java_options"] # optional
#    wrapper:
#        config["version"] + "/bio/gatk/variantfiltration"
#
#rule bcftools:
#    input:
#        "/home/OutputFiles/VCF/HaplotypeCaller/2-Filtered/{sample}_filtered.vcf.gz"
#    output:
#        "/home/OutputFiles/VCF/HaplotypeCaller/3-Final/{sample}.vcf.gz"
#    params:
#        genome_version = config["genome_version"]
#    shell:
#        "if echo {params.genome_version} | grep hg38; then echo '##reference=GRCh38' > /home/header.hdr && bcftools annotate -Oz -h /home/header.hdr {input} > {output}; elif echo {params.genome_version} | grep hg19;  then  echo '##reference=GRCh37' > /home/header.hdr && bcftools annotate -Oz -h /home/header.hdr {input} > {output};else echo 'ERROR'; fi" 
