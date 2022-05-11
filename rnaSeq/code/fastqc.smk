import sys
sys.path.append('/home/Utils/')
from pipeline import *

sed(4, wildcard("/home/FastQ/", ["_R1",".R1","-R1"])[1], "/home/Utils/config.yaml")

configfile: "/home/Utils/config.yaml"

rule all:
    input:
        expand("/home/OutputFiles/QC/1-BeforeTrimming/{ID}.{ext}", ID=wildcard('/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/',['.fastq'])[0], ext=["zip", "html"])

rule fastqc:
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
