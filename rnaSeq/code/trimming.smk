import sys
sys.path.append('/home/Utils/')
from pipeline import *

sed(4, wildcard("/home/Data/FastQ/", ["_R1",".R1","-R1"])[1], "/home/Utils/config.yaml")

configfile: "/home/Utils/config.yaml"

rule all:
    input:
        expand("/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{ID}_R1_paired.fastq", ID=wildcard('/home/Data/FastQ/', ['_R1','.R1','-R1'])[0]),
        expand("/home/{ID}_R2_paired.fastq", ID=wildcard('/home/Data/FastQ/', ['_R1','.R1','-R1'])[0]),
        #expand("/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Unpaired/{ID}_R1_unpaired.fastq", ID=wildcard('/home/Data/FastQ/', ['_R1','.R1','-R1'])[0]),
        #expand("/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Unpaired/{ID}_R2_unpaired.fastq", ID=wildcard('/home/Data/FastQ/', ['_R1','.R1','-R1'])[0])

rule trimmomatic_trimFirstBase:
    input:
        #r1 = 
        "/home/Data/FastQ/{sample}" + config["nomenclature"]["Sep"] + "R1" + config["nomenclature"]["End"],
        #r2 = "/home/Data/FastQ/{sample}" + config["nomenclature"]["Sep"] + "R2" + config["nomenclature"]["End"]
    output:
        "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{sample}_R1_paired.fastq",
	#    r1_unpaired = "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Unpaired/{sample}_R1_unpaired.fastq",
	#    r2 = "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{sample}_R2_paired.fastq",
	#    r2_unpaired = "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Unpaired/{sample}_R2_unpaired.fastq"
    params:
        trimmer = config["TrimmomaticFirstBase_parameters"],
        extra = config["TrimmomaticFirstBase_phred"]
    threads:
        config["TrimmomaticFirstBase_threads"]
    log:
        "/home/Log/02_TRIMMOMATIC_{sample}.log"
    benchmark:
        "/home/Benchmark/02_TRIMMOMATIC_{sample}.txt"
    wrapper:
        config["version"] + "/bio/trimmomatic/se"

rule copyR2:
    input:
        "/home/Data/FastQ/{sample}" + config["nomenclature"]["Sep"] + "R2" + config["nomenclature"]["End"]
    output:
        "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{sample}_R2_paired.fastq.gz"
    shell:
        "cp {input} {output}"

rule DecompressR2:
    input:
        "/home/OutputFiles/FastQ/ReadsTrimmed_FirstBase/Paired/{sample}_R2_paired.fastq.gz"
    output:
        "/home/{sample}_R2_paired.fastq"
    shell:
        "bgzip -d {input} && touch {output}"
