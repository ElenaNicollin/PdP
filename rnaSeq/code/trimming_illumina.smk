import sys
sys.path.append('/home/Utils/')
from pipeline import *

sed(4, wildcard("/home/Data/FastQ/", ["_R1",".R1","-R1"])[1], "/home/Utils/config.yaml")

configfile: "/home/Utils/config.yaml"

rule all:
    input:
        #expand("/home/OutputFiles/QC/0-BeforeTrimmingFirstBase/{ID}.{ext}", ID=wildcard('/home/Data/FastQ/', ['.fastq'])[0], ext=["html", "zip"]),
        expand("/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{ID}_R1_paired.fastq", ID=wildcard('/home/Data/FastQ/', ['_R1','.R1','-R1'])[0]),
        expand("/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{ID}_R2_paired.fastq", ID=wildcard('/home/Data/FastQ/', ['_R1','.R1','-R1'])[0]),
        expand("/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Unpaired/{ID}_R1_unpaired.fastq", ID=wildcard('/home/Data/FastQ/', ['_R1','.R1','-R1'])[0]),
        expand("/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Unpaired/{ID}_R2_unpaired.fastq", ID=wildcard('/home/Data/FastQ/', ['_R1','.R1','-R1'])[0])

rule fastqc:
    input:
        "/home/OutputFiles/FastQ/{sample}" + config["nomenclature"]["Sep"] + "R1" + config["nomenclature"]["End"]
    output:
        html="/home/OutputFiles/QC/0-BeforeTrimmingFirstBase/{sample}.html",
        zip="/home/OutputFiles/QC/0-BeforeTrimmingFirstBase/{sample}.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    params: config["FASTQC-AT_parameters"]
    log:
        "/home/Log/00_FASTQC-BEFORE_FIRSTBASE_{sample}.log"
    benchmark:
        "/home/Benchmark/00_FASTQC-BEFORE_FIRSTBASE_{sample}.txt"
    wrapper:
        config["version"] + "/bio/fastqc"

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
