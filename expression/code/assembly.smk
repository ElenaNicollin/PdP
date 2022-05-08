import sys
sys.path.append('/home/Utils/')
from pipeline import wildcard

configfile: "/home/Utils/config.yaml"

rule all:
    input:
        expand("/home/OutputFiles/GTF/{ID}/{ID}.gtf", ID=wildcard('/home/BAM/', ['.bam.bai'])[0]),
        expand("/home/OutputFiles/GTF/{ID}/{ID}_abundance.txt", ID=wildcard('/home/BAM/', ['.bam.bai'])[0]),

rule stringtie:
    input:
        "/home/BAM/{sample}.bam"
    output:
        gtf="/home/OutputFiles/GTF/{sample}/{sample}.gtf",
        abund="/home/OutputFiles/GTF/{sample}/{sample}_abundance.txt",
    params:
        library=config["StringTie_stranded_library"],
        genome=config["ref"],
    shell:
        "stringtie {params.library} -A {output.abund} -B -e -G {params.genome} -o {output.gtf} {input}"

rule prepDE:
    input:
        "/home/OutputFiles/GTF/"
    output:
        gene="/home/OutputFiles/count_matrices/gene_count_matrix.csv",
        transcript="/home/OutputFiles/count_matrices/transcript_count_matrix.csv",
    shell:
        "echo Creating count matrices... ; python /home/Utils/prepDE.py -i {input} -g {output.gene} -t {output.transcript}"