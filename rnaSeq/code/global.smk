import sys
sys.path.append('/home/Utils/')
from pipeline import *

sed(4, wildcard("/home/Data/FastQ/", ["_R1",".R1","-R1"])[1], "/home/Utils/config.yaml")

configfile: "/home/Utils/config.yaml"


rule all:
    input:
        expand("/home/OutputFiles/QC/0-BeforeTrimmingFirstBase/{ID}.{ext}", ID=wildcard('/home/Data/FastQ/', ['.fastq'])[0], ext=["html", "zip"]),
        expand("/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Unpaired/{ID}_R1_unpaired.fastq", ID=wildcard('/home/Data/FastQ/', ['_R1','.R1','-R1'])[0]),
        expand("/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Unpaired/{ID}_R2_unpaired.fastq", ID=wildcard('/home/Data/FastQ/', ['_R1','.R1','-R1'])[0]),
        expand("/home/OutputFiles/QC/1-BeforeTrimming/{ID}.{ext}", ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',['.fastq'])[0], ext=["zip", "html"]),
        expand("/home/OutputFiles/BAM/7-BQSR/{ID}.bai",ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',["_R1"])[0]),
        expand("/home/tmp/{ID}.txt",ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',["_R1"])[0]),
        expand("/home/PicardHSMetrics/{ID}.txt",ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',["_R1"])[0]),
        expand("/home/OutputFiles/BAM/8-UnmappedReads/{ID}.bam",ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',["_R1"])[0]),
        expand("/home/OutputFiles/QC/2-AfterTrimming/{ID}_{R}.{ext}", ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',["_R1"])[0], R=["R1_paired", "R2_paired"] , ext=["html", "zip"]),
        expand("/home/OutputFiles/QC/2-AfterTrimming/{ID}_{R}.{ext}", ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',["_R1"])[0], R=["R1_unpaired", "R2_unpaired"] , ext=["html", "zip"]),
        expand("/home/OutputFiles/QC/3-FlagstatReadsMapped/08_SAMTOOLS-FLAGSTAT_{ID}.txt", ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',["_R1"])[0]),
        expand("/home/OutputFiles/QC/8-FlagstatBQSR/16_SAMTOOLS-FLAGSTAT_{ID}.txt", ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',["_R1"])[0]),
        expand("/home/OutputFiles/QC/6-QualimapAfterRMDup/{ID}/", ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',["_R1"])[0]),
        expand("/home/OutputFiles/QC/7-QualimapAfterRecalibration/{ID}/", ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',["_R1"])[0]),


#rule fastqc:
#    input:
#        "/home/OutputFiles/FastQ/{sample}" + config["nomenclature"]["Sep"] + "R1" + config["nomenclature"]["End"]
#    output:
#        html="/home/OutputFiles/QC/0-BeforeTrimmingFirstBase/{sample}.html",
#        zip="/home/OutputFiles/QC/0-BeforeTrimmingFirstBase/{sample}.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
#    params: config["FASTQC-AT_parameters"]
#    log:
#        "/home/Log/00_FASTQC-BEFORE_FIRSTBASE_{sample}.log"
#    benchmark:
#        "/home/Benchmark/00_FASTQC-BEFORE_FIRSTBASE_{sample}.txt"
#    wrapper:
#        config["version"] + "/bio/fastqc"

rule trimmomatic_trimFirstBase:
    input:
        r1 = "/home/Data/FastQ/{sample}" + config["nomenclature"]["Sep"] + "R1" + config["nomenclature"]["End"],
        r2 = "/home/Data/FastQ/{sample}" + config["nomenclature"]["Sep"] + "R2" + config["nomenclature"]["End"]
    output:
        r1 = "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{sample}_R1_paired.fastq",
	    r1_unpaired = "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Unpaired/{sample}_R1_unpaired.fastq",
	    r2 = "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{sample}_R2_paired.fastq",
	    r2_unpaired = "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Unpaired/{sample}_R2_unpaired.fastq"
    params:
        trimmer = config["TrimmomaticIllumina_parameters"],
        extra = config["TrimmomaticIllumina_phred"]
    threads:
        config["TrimmomaticIllumina_threads"]
    log:
        "/home/Log/02_TRIMMOMATIC_{sample}.log"
    benchmark:
        "/home/Benchmark/02_TRIMMOMATIC_{sample}.txt"
    wrapper:
        config["version"] + "/bio/trimmomatic/pe"


rule fastqc2:
    input:
        "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{sample}.fastq"
    output:
        zip="/home/OutputFiles/QC/1-BeforeTrimming/{sample}.zip", # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
        html="/home/OutputFiles/QC/1-BeforeTrimming/{sample}.html"
    params: 
        config["FASTQC_parameters"]
    log:
        "/home/Log/01_FASTQC_{sample}.log"
    benchmark:
        "/home/Benchmark/01_FASTQC_{sample}.txt"
    wrapper:
        config["version"] + "/bio/fastqc"

rule trimmomatic:
    input:
        r1 = "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{sample}_R1_paired.fastq",
        r2 = "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{sample}_R2_paired.fastq"
    output:
        r1 = "/home/OutputFiles/FastQ/ReadsTrimmed/Paired/{sample}_R1_paired.fastq",
        r1_unpaired = "/home/OutputFiles/FastQ/ReadsTrimmed/Unpaired/{sample}_R1_unpaired.fastq",
        r2 = "/home/OutputFiles/FastQ/ReadsTrimmed/Paired/{sample}_R2_paired.fastq",
        r2_unpaired = "/home/OutputFiles/FastQ/ReadsTrimmed/Unpaired/{sample}_R2_unpaired.fastq"
    params:
        trimmer = config["Trimmomatic_parameters"],
        extra = config["Trimmomatic_phred"]
    threads:
        config["Trimmomatic_threads"]
    log:
        "/home/Log/03_TRIMMOMATIC_{sample}.log"
    benchmark:
        "/home/Benchmark/03_TRIMMOMATIC_{sample}.txt"
    wrapper:
        config["version"] + "/bio/trimmomatic/pe"

rule fastqc3:
    input:
        "/home/OutputFiles/FastQ/ReadsTrimmed/Paired/{sample}.fastq"
    output:
        html="/home/OutputFiles/QC/2-AfterTrimming/{sample}.html",
        zip="/home/OutputFiles/QC/2-AfterTrimming/{sample}.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    params: config["FASTQC-AT_parameters"]
    log:
        "/home/Log/04_FASTQC-AT-Paired_{sample}.log"
    benchmark:
        "/home/Benchmark/04_FASTQC-AT-Paired_{sample}.txt"
    wrapper:
        config["version"] + "/bio/fastqc"
    
rule fastqc4:
    input:
        "/home/OutputFiles/FastQ/ReadsTrimmed/Unpaired/{sample}.fastq"
    output:
        html="/home/OutputFiles/QC/2-AfterTrimming/{sample}.html",
        zip="/home/OutputFiles/QC/2-AfterTrimming/{sample}.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    params: config["FASTQC-AT_parameters"]
    log:
        "/home/Log/05_FASTQC-AT-Unpaired_{sample}.log"
    benchmark:
        "/home/Benchmark/05_FASTQC-AT-Unpaired_{sample}.txt"
    wrapper:
        config["version"] + "/bio/fastqc"


rule star_pe_multi:
    input:
        # use a list for multiple fastq files for one sample
        # usually technical replicates across lanes/flowcells
        fq1 = ["/home/OutputFiles/FastQ/ReadsTrimmed/Paired/{sample}_R1_paired.fastq"],
        # paired end reads needs to be ordered so each item in the two lists match
        fq2 = ["/home/OutputFiles/FastQ/ReadsTrimmed/Paired/{sample}_R2_paired.fastq"]
    output:
        # see STAR manual for additional output files
        "/home/OutputFiles/SAM/{sample}/Aligned.out.sam"
    log:
        "/home/Log/06_STAR_{sample}.log"
    benchmark:
        "/home/Benchmark/06_STAR_{sample}.txt"
    params:
        # path to STAR reference genome index
        index=config["STAR_index"],
        # optional parameters
        extra=config["STAR_parameters"]
    threads: config["STAR_threads"]
    wrapper:
        config["version"] + "/bio/star/align"


rule samtools_view:
    input:
        "/home/OutputFiles/SAM/{sample}/Aligned.out.sam"
    output:
        "/home/OutputFiles/BAM/1-ReadsMapped/{sample}.bam"
    params:
        config["Samtools-VIEW_parameters"] # optional params string
    log:
        "/home/Log/07_SAMTOOLS-VIEW_{sample}.log"
    benchmark:
        "/home/Benchmark/07_SAMTOOLS-VIEW_{sample}.txt"
    wrapper:
        config["version"] + "/bio/samtools/view"

rule samtools_flagstat1:
    input:
        "/home/OutputFiles/BAM/1-ReadsMapped/{sample}.bam"
    output:
        "/home/OutputFiles/QC/3-FlagstatReadsMapped/08_SAMTOOLS-FLAGSTAT_{sample}.txt"
    log:
        "/home/Log/08_SAMTOOLS-FLAGSTAT_{sample}.log"
    benchmark:
        "/home/Benchmark/08_SAMTOOLS-FLAGSTAT_{sample}.txt"
    wrapper:
        config["version"] + "/bio/samtools/flagstat"

rule count_fastq_reads:
    input:
        r1_paired = "/home/OutputFiles/QC/2-AfterTrimming/{sample}_R1_paired.zip",
        r2_paired = "/home/OutputFiles/QC/2-AfterTrimming/{sample}_R2_paired.zip",
        r1_unpaired = "/home/OutputFiles/QC/2-AfterTrimming/{sample}_R1_unpaired.zip",
        r2_unpaired = "/home/OutputFiles/QC/2-AfterTrimming/{sample}_R2_unpaired.zip",
        flagstat = "/home/OutputFiles/QC/3-FlagstatReadsMapped/08_SAMTOOLS-FLAGSTAT_{sample}.txt"
    output:
        "/home/tmp/{sample}.txt"
    shell:
        "if ! grep -q 'FastQ_R1_Paired :' {input.flagstat}; then /home/Utils/./fastq_reads.sh {input.r1_paired} {input.r1_unpaired} {input.r2_paired} {input.r2_unpaired} {input.flagstat} {output}; else touch {output}; fi"

rule sort_bam1:
    input:
        "/home/OutputFiles/BAM/1-ReadsMapped/{sample}.bam"
    output:
        "/home/OutputFiles/BAM/2-ReadsSorted/{sample}.bam"
    log:
        "/home/Log/09_SortSam_{sample}.log"
    benchmark:
        "/home/Benchmark/09_SortSam_{sample}.log"
    params:
        sort_order="coordinate",
        extra="VALIDATION_STRINGENCY=STRICT"
    wrapper:
        config["version"] + "/bio/picard/sortsam"

rule replace_rg:
    input:
        "/home/OutputFiles/BAM/2-ReadsSorted/{sample}.bam"
    output:
        "/home/OutputFiles/BAM/5-ReadGroups/{sample}.bam"
    log:
        "/home/Log/13_AddOrReplaceReadGroups_{sample}.log"
    benchmark:
        "/home/Benchmark/13_AddOrReplaceReadGroups_{sample}.txt"
    params:
        "RGLB=lib1 RGPL=illumina RGPU={sample} RGSM={sample} RGID={sample}"
    wrapper:
        config["version"] + "/bio/picard/addorreplacereadgroups"


rule QualimapDuplicates:
    input:
        "/home/OutputFiles/BAM/5-ReadGroups/{sample}.bam"
    output:
        directory("/home/OutputFiles/QC/6-QualimapAfterRMDup/{sample}/")
    log:
        "/home/Log/14_Qualimap_{sample}.log"
    benchmark:
        "/home/Benchmark/14_Qualimap_{sample}.txt"
    params:
        extra=config["Qualimap_AfterRMDup"]
    shell:
        "/home/Qualimap/./qualimap rnaseq {params.extra} -bam {input} -gtf /home/human.gtf -outdir {output}"

rule splitncigarreads:
    input:
        bam="/home/OutputFiles/BAM/5-ReadGroups/{sample}.bam",
        ref=config["ref"]
    output:
        "/home/OutputFiles/BAM/6-SplitNCigarReads/{sample}.bam"
    log:
        "/home/Log/15_SlitNCigarReads_{sample}.log"
    benchmark:
        "/home/Benchmark/15_SlitNCigarReads_{sample}.txt"
    params:
        extra=config["SplitNCIGARreads_parameters"],  # optional
        java_opts=config["SplitNCIGARreads_java_options"],  # optional
    wrapper:
        config["version"] + "/bio/gatk/splitncigarreads"

rule gatk_bqsr:
    input:
        bam="/home/OutputFiles/BAM/6-SplitNCigarReads/{sample}.bam",
        ref=config["ref"],
        known=config["known"]  # optional known sites
    output:
        bam="/home/OutputFiles/BAM/7-BQSR/{sample}.bam"
    log:
        "/home/Log/16_BaseRecalibrator+ApplyBQSR_{sample}.log"
    benchmark:
        "/home/Benchmark/16_BaseRecalibrator+ApplyBQSR_{sample}.txt"
    params:
        extra=config["BQSR_parameters"],  # optional
        java_opts=config["BQSR_java_options"] # optional
    wrapper:
        config["version"] + "/bio/gatk/baserecalibrator"

rule QualimapAfterCalibration:
    input:
        "/home/OutputFiles/BAM/7-BQSR/{sample}.bam"
    output:
        directory("/home/OutputFiles/QC/7-QualimapAfterRecalibration/{sample}/")
    log:
        "/home/Log/17_Qualimap_{sample}.log"
    benchmark:
        "/home/Benchmark/17_Qualimap_{sample}.txt"
    params:
        extra=config["Qualimap_AfterRecalibration"]
    shell:
        "/home/Qualimap/./qualimap rnaseq {params.extra} -bam {input} -gtf /home/gtf -outdir {output}"

rule samtools_flagstat3:
    input:
        "/home/OutputFiles/BAM/7-BQSR/{sample}.bam"
    output:
        "/home/OutputFiles/QC/8-FlagstatBQSR/16_SAMTOOLS-FLAGSTAT_{sample}.txt"
    log:
        "/home/Log/18_SAMTOOLS-FLAGSTAT_{sample}.log"
    benchmark:
        "/home/Benchmark/18_SAMTOOLS-FLAGSTAT_{sample}.txt"
    wrapper:
        config["version"] + "/bio/samtools/flagstat"

rule samtools_index:
    input:
        "/home/OutputFiles/BAM/7-BQSR/{sample}.bam"
    output:
        "/home/OutputFiles/BAM/7-BQSR/{sample}.bai"
    log:
        "/home/Log/19_SAMTOOLS-INDEX_{sample}.log"
    benchmark:
        "/home/Benchmark/19_SAMTOOLS-INDEX_{sample}.txt"
    params:
        config["Samtools-INDEX_parameters"] # optional params string
    wrapper:
        config["version"] + "/bio/samtools/index"

rule samtools_unmapped:
    input:
        "/home/OutputFiles/BAM/7-BQSR/{sample}.bam"
    output:
        "/home/OutputFiles/BAM/8-UnmappedReads/{sample}.bam"
    params:
        config["Samtools-VIEW2_parameters"] # optional params string
    log:
        "/home/Log/071_SAMTOOLS-VIEW2_{sample}.log"
    benchmark:
        "/home/Benchmark/071_SAMTOOLS-VIEW2_{sample}.txt"
    wrapper:
        config["version"] + "/bio/samtools/view"

rule picard_collect_hs_metrics:
    input:
        bam="/home/OutputFiles/BAM/7-BQSR/{sample}.bam",
        reference=config["ref"],
        # Baits and targets should be given as interval lists. These can
        # be generated from bed files using picard BedToIntervalList.
        bait_intervals=config["bait_intervals"],
        target_intervals=config["target_intervals"]
    output:
        "/home/PicardHSMetrics/{sample}.txt"
    params:
        # Optional extra arguments. Here we reduce sample size
        # to reduce the runtime in our unit test.
        extra=config["PicardsHSMetrics_parameters"]
    log:
        "/home/Log/20_PicardHSMetrics_{sample}.log"
    benchmark:
        "/home/Benchmark/20_PicardHSMetrics_{sample}.txt"
    wrapper:
        config["version"] + "/bio/picard/collecthsmetrics"
