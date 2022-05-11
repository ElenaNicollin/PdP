import sys
sys.path.append('/home/Utils/')
from pipeline import *

configfile: "/home/Utils/config.yaml"

rule all:
    input:
        expand("/home/OutputFiles/QC/2-AfterTrimming/{ID}.{ext}", ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed/Paired/',['.fastq'])[0], ext=["zip", "html"]),
        #expand("/home/OutputFiles/QC/3-Screen/{ID}.fastq_screen.{ext}",ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed/Paired/',['.fastq'])[0], ext=["txt", "png"])

rule fastqc2:
    input:
        "/home/OutputFiles/FastQ/ReadsTrimmed/Paired/{sample}.fastq"
    output:
        html="/home/OutputFiles/QC/2-AfterTrimming/{sample}.html",
        zip="/home/OutputFiles/QC/2-AfterTrimming/{sample}.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    params: 
        config["FASTQC-AT_parameters"]
    benchmark:
        "/home/Benchmark/011_FASTQC-AT_{sample}.txt"
    wrapper:
        config["version"] + "/bio/fastqc"

rule fastq_screen:
    input:
        "/home/OutputFiles/FastQ/ReadsTrimmed/Paired/{sample}.fastq"
    output:
        txt="/home/OutputFiles/QC/3-Screen/{sample}.fastq_screen.txt",
        png="/home/OutputFiles/QC/3-Screen/{sample}.fastq_screen.png"
    params:
        fastq_screen_config=config["FastQ_Screen_conf"],
        subset=config["FastQ_Screen_subset"],
        aligner=config["FastQ_Screen_aligner"]
    log:
        "/home/Log/03_FASTQ-SCREEN_{sample}.log"
    threads: config["FASTQ-SCREEN_threads"]
    wrapper:
        config["version"] + "/bio/fastq_screen"
