import sys
sys.path.append('/home/Utils/')
from pipeline import *

configfile: "/home/Rules/Mapping/STAR/config.yaml"

rule all2:
    input:
        expand("/home/OutputFiles/SAM/{ID}/Aligned.out.sam", ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed/Paired/',['.R1','-R1','_R1'])[0]),

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
