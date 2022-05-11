import sys
sys.path.append('/home/Utils/')
import gvcf
import subprocess
import glob

configfile : "/home/Rules/VariantCalling/HaplotypeCaller/config.yaml"

gvcf.create_sample_map("/home/SampleSheet/formulaire.txt","/home/OutputFiles/SampleMap/")
subprocess.check_output(['/home/Utils/interval.sh', "/home/SampleSheet/"]).decode("utf-8").strip()

rule all:
    input:
        expand("/home/OutputFiles/GVCF/HaplotypeCaller/3-Final/{ID}.g.vcf.gz.tbi", ID=gvcf.wildcard(gvcf.read("/home/SampleSheet/formulaire.txt"))),
        expand("/home/OutputFiles/VCF/HaplotypeCaller/1-NoFiltered/{ID}.vcf.gz.tbi", ID=gvcf.wildcard(gvcf.read("/home/SampleSheet/formulaire.txt"))),
        expand("/home/OutputFiles/VCF/HaplotypeCaller/2-BedFiltered/{ID}.vcf", ID=gvcf.wildcard(gvcf.read("/home/SampleSheet/formulaire.txt")))

rule genomicDBimport:
    input:
        "/home/OutputFiles/SampleMap/{sample}.sample_map"
    output:
        directory("/home/OutputFiles/GVCF/HaplotypeCaller/2-Database/{sample}")
    benchmark:
        "/home/Benchmark/18_GenomicsDB_{sample}.txt"
    log:
        "/home/Log/18_GenomicsDB_{sample}.log"
    params:
        extra=config["GenomicsDB_parameters"],
        interval=subprocess.check_output(['/home/Utils/interval.sh', "/home/SampleSheet/"]).decode("utf-8").strip(),
        java_opts=config["GenomicsDB_java_options"]
    shell:
        "/home/gatk/./gatk --java-options {params.java_opts} GenomicsDBImport --sample-name-map {input} -L {params.interval} {params.extra} 2>&1 --genomicsdb-workspace-path {output} | tee -a {log}"

rule select_variants:
    input:
        db="/home/OutputFiles/GVCF/HaplotypeCaller/2-Database/{sample}",
        ref=config["ref"],
        intervals="/home/SampleSheet/intervals.list"
    output:
        gvcf = "/home/OutputFiles/GVCF/HaplotypeCaller/3-Final/{sample}.g.vcf.gz"
    threads:
        3
    benchmark:
        "/home/Benchmark/19_SelectVariants_{sample}.txt"
    log:
        "/home/Log/19_SelectVariants_{sample}.log"
    params:
        extra=config["SelectVariants_parameters"],
        java_opts=config["SelectVariants_java_options"],
        threads=config["SelectVariants_threads"],
        bcftools=config["BCFToolsSelectVariants_threads"]
    script:
        "/home/Utils/selectVariants.py"

rule select_variants_indexage:
    input:
        "/home/OutputFiles/GVCF/HaplotypeCaller/3-Final/{sample}.g.vcf.gz"
    output:
        index="/home/OutputFiles/GVCF/HaplotypeCaller/3-Final/{sample}.g.vcf.gz.tbi"
    threads:
        3
    params:
        extra=config["IndexFeatureFileSV_parameters"]
    log:
        "/home/Log/22_IndexFeatureFile_{sample}.log"
    benchmark:
        "/home/Benchmark/22_IndexFeatureFile_{sample}.txt"
    shell:
        "/home/gatk/./gatk IndexFeatureFile --version >> log &&"
        "/home/gatk/./gatk IndexFeatureFile -I {input} 2>&1 {params.extra} -O {output.index} | tee -a log" 

rule genotype_gvcfs:
    input:
        db="/home/OutputFiles/GVCF/HaplotypeCaller/2-Database/{sample}",
        ref=config["ref"],
	intervals="/home/SampleSheet/intervals.list"
    output:
        vcf="/home/OutputFiles/VCF/HaplotypeCaller/1-NoFiltered/{sample}.vcf.gz"
    benchmark:
        "/home/Benchmark/20_GenotypeGVCFs_{sample}.txt"
    log:
        "/home/Log/20_GenotypeGVCFs_{sample}.log"
    params:
        extra=config["GenotypeGVCFs_parameters"],  # optional
        java_opts=config["GenotypeGVCFs_java_options"], # optional
        threads=config["GenotypeGVCFs_threads"],
        bcftools=config["BCFToolsGenotype_threads"]
    script:
        "/home/Utils/genotypeGVCF.py"

rule genotype_gvcfs_indexage:
    input:
        "/home/OutputFiles/VCF/HaplotypeCaller/1-NoFiltered/{sample}.vcf.gz"
    output:
        index="/home/OutputFiles/VCF/HaplotypeCaller/1-NoFiltered/{sample}.vcf.gz.tbi"
    params:
        extra=config["IndexFeatureFileGenotype_parameters"]
    log:
        "/home/Log/22_IndexFeatureFile_{sample}.log"
    benchmark:
        "/home/Benchmark/22_IndexFeatureFile_{sample}.txt"
    shell:
        "/home/gatk/./gatk IndexFeatureFile --version >> log &&"
        "/home/gatk/./gatk IndexFeatureFile -I {input} 2>&1 {params.extra} -O {output.index} | tee -a log" 

rule bed_filter:
    input:
        "/home/OutputFiles/VCF/HaplotypeCaller/1-NoFiltered/{sample}.vcf.gz"
    output:
        "/home/OutputFiles/VCF/HaplotypeCaller/2-BedFiltered/{sample}.vcf"
    params:
        extra = config["VCFTools_parameters"]
    benchmark:
        "/home/Benchmark/21_VCFTools_{sample}.txt"
    log:
        "/home/Log/21_VCFTools_{sample}.log"
    wrapper:
        config["version"] + "/bio/vcftools/filter"
