import sys
sys.path.append('/home/Utils/')
import gvcf
import subprocess

configfile : "/home/Rules/VariantCalling/HaplotypeCaller/config.yaml"

gvcf.create_sample_map("/home/SampleSheet/formulaire.txt","/home/OutputFiles/SampleMap/")

rule all:
    input:
        expand("/home/OutputFiles/VCF/HaplotypeCaller/4-Final/{ID}.vcf.gz", ID=gvcf.wildcard(gvcf.read("/home/SampleSheet/formulaire.txt"))),        
        expand("/home/OutputFiles/VCF/HaplotypeCaller/2-BedFiltered/{ID}.vcf.gz.tbi", ID=gvcf.wildcard(gvcf.read("/home/SampleSheet/formulaire.txt")))

rule bed_filter_indexing:
    input:
        "/home/OutputFiles/VCF/HaplotypeCaller/2-BedFiltered/{sample}.vcf.gz"
    output:
        index="/home/OutputFiles/VCF/HaplotypeCaller/2-BedFiltered/{sample}.vcf.gz.tbi"
    params:
        extra=config["IndexFeatureFile_parameters"]
    log:
        "/home/Log/22_IndexFeatureFile_{sample}.log"
    benchmark:
        "/home/Benchmark/22_IndexFeatureFile_{sample}.txt"
    shell:
        "/home/gatk/./gatk IndexFeatureFile --version >> log &&"
        "/home/gatk/./gatk IndexFeatureFile -I {input} 2>&1 {params.extra} -O {output.index} | tee -a log"        

rule gatk_filter:
    input:
        vcf="/home/OutputFiles/VCF/HaplotypeCaller/2-BedFiltered/{sample}.vcf.gz",
        ref=config["ref"]
    output:
        vcf="/home/OutputFiles/VCF/HaplotypeCaller/3-Filtered/{sample}_filtered.vcf.gz"
    benchmark:
        "/home/Benchmark/23_VariantFiltration_{sample}.txt"
    log:
        "/home/Log/23_VariantFiltration_{sample}.log"
    params:
        filters=config["VariantFiltration_filters"],
        extra=config["VariantFiltration_parameters"],  # optional arguments, see GATK docs
        java_opts=config["VariantFiltration_java_options"] # optional
    wrapper:
        config["version"] + "/bio/gatk/variantfiltration"

rule bcftools:
    input:
        "/home/OutputFiles/VCF/HaplotypeCaller/3-Filtered/{sample}_filtered.vcf.gz"
    output:
        "/home/OutputFiles/VCF/HaplotypeCaller/4-Final/{sample}.vcf.gz"
    params:
        genome_version = config["genome_version"]
    shell:
        "if echo {params.genome_version} | grep hg38; then echo '##reference=GRCh38' > /home/header.hdr && bcftools annotate -Oz -h /home/header.hdr {input} > {output}; elif echo {params.genome_version} | grep hg19;  then  echo '##reference=GRCh37' > /home/header.hdr && bcftools annotate -Oz -h /home/header.hdr {input} > {output};else echo 'ERROR'; fi" 

#rule variant_recalibrator:
#    input:
#        vcf="/home/OutputFiles/BAMFiltered/Calls/HaplotypeCaller/VCF/{sample}.vcf.gz",
#        ref=config["ref"],
        # resources have to be given as named input files
#        hapmap="/home/vqsr/hapmap_3.3.hg38.vcf.gz",
#        omni="/home/vqsr/1000G_omni2.5.hg38.vcf.gz",
#        g1k="/home/vqsr/1000G_phase1.snps.high_confidence.hg38.vcf.gz",
#        dbsnp="/home/vqsr/Homo_sapiens_assembly38.dbsnp138.vcf.gz",
        # use aux to e.g. download other necessary file
#        aux=["/home/vqsr/hapmap_3.3.hg38.vcf.gz.tbi",
#             "/home/vqsr/1000G_omni2.5.hg38.vcf.gz.tbi",
#             "/home/vqsr/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi",
#             "/home/vqsr/Homo_sapiens_assembly38.dbsnp138.vcf.gz.tbi"]
#    output:
#        vcf="/home/OutputFiles/BAMFiltered/Calls/HaplotypeCaller/VCF/Recalibration/{sample}.vcf.gz",
#        tranches="/home/OutputFiles/BAMFiltered/Calls/HaplotypeCaller/VCF/Recalibration/{sample}.tranches"
#    benchmark:
#        "/home/Benchmark/21_VariantRecalibrator_{sample}.txt"
#    log:
#        "/home/Log/21_VariantRecalibrator_{sample}.log"
#    params:
#        mode=config["VariantRecalibrator_mode"],  # set mode, must be either SNP, INDEL or BOTH
        # resource parameter definition. Key must match named input files from above.
#        resources=config["VariantRecalibrator_resources"],
#        annotation=config["VariantRecalibrator_annotation"],  # which fields to use with -an (see VariantRecalibrator docs)
#        extra=config["VariantRecalibrator_parameters"],  # optional
#        java_opts=config["VariantRecalibrator_java_opts"], # optional
#    script:
#        "/home/Utils/wrapper.py"
