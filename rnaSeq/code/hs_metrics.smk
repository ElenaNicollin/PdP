import sys
import glob
sys.path.append('/home/Utils/')
from pipeline import wildcard

configfile: "/home/Utils/config.yaml"

rule all:
    input:
        expand("/home/tmp/metrics/HS/{ID}.tsv",ID=wildcard('/home/PicardHSMetrics/',[".txt"])[0]),
        expand("/home/tmp/metrics/MD/{ID}.tsv",ID=wildcard('/home/OutputFiles/QC/4-DuplicatesMetrics/',[".metrics"])[0]),

rule splitDataHsMetrics:
    input:
        "/home/PicardHSMetrics/{sample}.txt"
    output:
        metrics = "/home/tmp/metrics/HS/{sample}.tsv"
    script:
        "/home/Utils/splitData.py"

rule splitDataMD:
    input:
        "/home/OutputFiles/QC/4-DuplicatesMetrics/{sample}.metrics.txt"
    output:
        metrics = "/home/tmp/metrics/MD/{sample}.tsv"
    script:
        "/home/Utils/splitData.py"
