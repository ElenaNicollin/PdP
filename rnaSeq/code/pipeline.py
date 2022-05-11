import os
import glob
import subprocess
import re
from urllib.request import urlopen, Request
import sys
import argparse
import yaml
#import pandas as pd
from datetime import datetime
#import json

def gff_or_not(path):
    for file in glob.glob(path + "**"):
        if ".bed" in file:
            return "-gff " + file
    return ""

def is_folder_existing(path):
    return os.path.exists(path)

def inputs():
    inputFiles = {"FastQ" : {"path" : "/home/Data/FastQ/", "ext" : ['.R1', '-R1', '_R1']}, "BAM" : {"path" : "/home/OutputFiles/BAM/7-BQSR/", "ext" : [".bam"]}, "VCF" : {"path": "/home/OutputFiles/VCF/3-Final/", "ext": [".vcf.gz"]}}
    if is_folder_existing("/home/Data/FastQ/"): 
        return inputFiles["FastQ"]["path"], inputFiles["FastQ"]["ext"] 
    if is_folder_existing("/home/OutputFiles/BAMFiltered/"):
        return inputFiles["BAM"]["path"], inputFiles["BAM"]["ext"] 
    if is_folder_existing("/home/OutputFiles/SampleMap/"):
        return inputFiles["VCF"]["path"], inputFiles["VCF"]["ext"] 

def wildcard(path, liste):
    dico = {}
    samples = []
    for file in glob.glob(path + "**", recursive=False):
        for pattern in liste:
            if pattern in file:
                split = re.split('/|' + pattern, file)
                filename, directory = split[-2], split[-3]
                dico['Sep'] = pattern[0] 
                dico['End'] = split[-1]
                samples.append(filename)
    return samples, dico

def read(path):
    return open(str(path),'r').readlines()

def write(path, data):
    f = open(str(path),'w')
    for i in range(len(data)):
        f.write(data[i])
    f.close()

def load(path):
    f = open(path,"r")
    data = f.readlines()
    common = data[0:3]
    version = "0.61.0"
    common.insert(0, "version : " + version  + "\n")
    f.close()
    start_aligner = create_config(common, 3, data, "/home/Utils/config.yaml")
    start_variantcall = create_config(common, start_aligner+1, data, "/home/Rules/Mapping/" + data[start_aligner].strip() + "/config.yaml")
    start = create_config(common, start_variantcall+1, data, "/home/Rules/VariantCalling/" + data[start_variantcall].strip() + "/config.yaml")
    if start != "FIN":
        while(data[start].strip() != "FIN"):
            start = create_config(common, start+1, data, "/home/Rules/VariantCalling/" + data[start].strip() + "/config.yaml")
    latest_version = update_version()
    new_version(version, latest_version)

def create_config(common, start, data, path):
    config = open(path, "w")
    for line in common:
        config.write(line)
    while (re.search(".* : ", data[start].strip())):
        config.write(data[start])
        start += 1
    config.close()
    return start

def sed(line, value, path):
    content = read(path)
    content[line-1] = content[line-1].replace(content[line-1], re.search('.* : ',content[line-1]).group() + str(value) + "\n")
    write(path, content)

def update_version():
    url = "https://github.com/snakemake/snakemake-wrappers/releases/latest"
    try:
        web_page = urlopen(url)
        url = web_page.geturl()
        version = re.search('\d.*',url).group()
        return version
    except:
        pass
        #logging ici
        
def elapsed_time(stop,start):
    a = stop.split(":")
    b = start.split(":")
    h = int(a[0]) - int(b[0])
    m = int(a[1]) - int(b[1])
    if h < 0:
        h += 24
    if m < 0:
        m += 60
    print("Elapsed time : {}h {}min".format(h,m))

def download_html(url, path):
    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.3'}
        reg_url = url
        req = Request(url=reg_url, headers=headers) 
        html = urlopen(req).read() 
        f = open(path, "wb")
        f.write(html)
        f.close()
    except:
        pass
        #login webpage changed

def new_version(current_version, latest_version):
    if current_version != latest_version:
        if os.path.isfile("/home/version/new_version.txt"):
            f = open("/home/version/new_version.txt", "a")
        else:
            f = open("/home/version/new_version.txt", "w")
        f.write("New wrapper version available for snakemake\n")
        f.write("Current version : " + str(current_version) + "\n")
        f.write("Latest version : " + str(latest_version) + "\n")
        f.close()

def check_process_failed(dict_process, path):
    f = open(path, 'w')
    for key in dict_process.keys():
        if dict_process[key]["code"] == 1:
            f.write("One process returned an error in " + key + " process : \n")
            f.write(subprocess.check_output(["cat", dict_process[key]["stderr"]]).decode("utf-8"))
            f.write("\n\n")
    f.close()

def check_pipeline_created_all_files():
    path, ext = inputs()
    samples = wildcard(path, ext)[0]
    count = 0
    vcs = ["HaplotypeCaller", "Strelka", "FreeBayes", "Mpileup"]
    vcs_used = []
    file_path = {"HaplotypeCaller" : { "path" : ["/home/OutputFiles/VCF/HaplotypeCaller/3-Final/"] }}
    for directory in os.listdir("/home/OutputFiles/VCF/"):
        if directory in vcs:
            vcs_used.append(directory)
    for vc in vcs_used:
        for path in file_path[vc]["path"]:
            for file in os.listdir(path):
                if file.split('.')[0] or file in samples:
                    count += 1
    if count == len(samples)*len(vcs_used):
        return True
    return False

#Permet de creer un vcf.gz une fois les vcf des chromosomes concatenes pour SelectVariants et GenotypeGVCFs
def bgzip(path):
    for file in glob.glob(path + "*"):
        if file.split('.')[1] == "vcf":
            subprocess.call(["bgzip", file])

def run_pipeline(path, cores, nameRun):
    load(path)
    check = {}

    print("File configuration loaded ...")
    download_html("https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/trimmomatic/pe.html", "/home/Log/pe.html")
    download_html("https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/samtools/view.html", "/home/Log/view.html")

    print("Get sequencing kit name ...")
    with open("/home/Utils/config.yaml") as file:
        config = yaml.load(file, Loader=yaml.SafeLoader)
        sequencing_kit = config["Sequencing_kit"]
        if sequencing_kit == "illumina":
            print("Illumina sequencing kit")
            print("Trimming first base running ... ")
            trimming_stderr = "/home/Log/trimming.log"
            trimming = subprocess.call(["snakemake", "--snakefile", "/home/Trimming/Illumina/Snakefile", "--cores", cores, "--use-conda", "--restart-times", "3"], stderr=open(trimming_stderr,"w"))
            check["trimming"] = {"code" : trimming, "stderr" : trimming_stderr}
        elif sequencing_kit == "takara":
            print("Takara sequencing kit")
            print("Trimming first base running ... ")
            trimming_stderr = "/home/Log/trimming.log"
            trimming = subprocess.call(["snakemake", "--snakefile", "/home/Trimming/Takara/Snakefile", "--cores", cores, "--use-conda", "--restart-times", "3"], stderr=open(trimming_stderr,"w"))
            check["trimming"] = {"code" : trimming, "stderr" : trimming_stderr}
        else:
            print("Error, wrong sequencing kit name specified in config file")

    #print("Trimming first base running ... ")
    #trimming_stderr = "/home/Log/trimming.log"
    #trimming = subprocess.call(["snakemake", "--snakefile", "/home/Trimming/Snakefile", "--cores", cores, "--use-conda", "--restart-times", "3"], stderr=open(trimming_stderr,"w"))
    #check["trimming"] = {"code" : trimming, "stderr" : trimming_stderr}

    print ("FastQC reporting ... ")
    fastqc_stderr = "/home/Log/fastqc.log"
    fastqc = subprocess.call(["snakemake", "--snakefile", "/home/FastQC/Snakefile", "--cores", cores, "--use-conda", "--restart-times", "3"], stderr=open(fastqc_stderr,"w"))
    check["fastqc"] = {"code" : fastqc, "stderr" : fastqc_stderr}

    # print("Trimming running ... ")
    # trimming_stderr = "/home/Log/trimming.log"
    # trimming = subprocess.call(["snakemake", "--snakefile", "/home/Trimming/Snakefile", "--cores", cores, "--use-conda"], stderr=open(trimming_stderr,"w"))
    # check["trimming"] = {"code" : trimming, "stderr" : trimming_stderr}

    # print("FastQC after trimming running ... ")
    # fastqc2_stderr = "/home/Log/fastqc2.log"
    # fastqc2 = subprocess.call(["snakemake", "--snakefile", "/home/FastQC2/Snakefile", "--cores", cores, "--use-conda"], stderr=open(fastqc2_stderr,"w"))
    # check["fastqc2"] = {"code" : fastqc, "stderr" : fastqc2_stderr}

    #print("Mapping running ... ")
    #mapping_stderr = "/home/Log/mapping.log"
    #mapping = subprocess.call(["snakemake", "--snakefile", "/home/Rules/Mapping/STAR/Snakefile", "--cores", cores, "--use-conda"], stderr=open(mapping_stderr,"w"))
    #check["mapping"] = {"code" : mapping, "stderr" : mapping_stderr}

    print("Pre-processing running ... ")
    preprocessing_stderr = "/home/Log/preprocessing.log"
    preprocessing = subprocess.call(["snakemake", "--snakefile", "/home/Pre_processing/Snakefile", "--cores", cores, "--use-conda", "--restart-times", "3"], stderr=open(preprocessing_stderr, "w"))
    check["preprocessing"] = {"code" : preprocessing, "stderr" : preprocessing_stderr}

    print("HaplotypeCaller running ...")
    start = datetime.now()
    start_time = start.strftime("%H:%M")
    hc1_stderr = "/home/Log/haplotype_part_1.log"
    hc1 = subprocess.call(["snakemake", "--snakefile", "/home/Rules/VariantCalling/HaplotypeCaller/Part1/Snakefile", "--cores", cores, "--use-conda", "--nolock", "--restart-times", "3"],stderr=open(hc1_stderr,"w"))
    check["hc1"] = {"code" : hc1, "stderr" : hc1_stderr}
    stop = datetime.now()
    stop_time = stop.strftime("%H:%M")
    print("Haplotype part 1")
    elapsed_time(stop_time, start_time)

    start = datetime.now()
    start_time = start.strftime("%H:%M")
    hc2_stderr = "/home/Log/haplotype_part_2.log"
    hc2 = subprocess.call(["snakemake", "--snakefile", "/home/Rules/VariantCalling/HaplotypeCaller/Part2/Snakefile", "--cores", cores, "--use-conda", "--nolock", "--restart-times", "3"],stderr=open(hc2_stderr,"w"))
    stop = datetime.now()
    stop_time = stop.strftime("%H:%M")
    print("Haplotype part 2")
    elapsed_time(stop_time, start_time)
    check["hc2"] = {"code" : hc2, "stderr" : hc2_stderr}

    bgzip("/home/OutputFiles/VCF/HaplotypeCaller/2-BedFiltered/")

    print("Filtration pipeline running ...")

    start = datetime.now()
    start_time = start.strftime("%H:%M")
    hc3_stderr = "/home/Log/haplotype_part_3.log"
    hc3 = subprocess.call(["snakemake", "--snakefile", "/home/Rules/VariantCalling/HaplotypeCaller/Part3/Snakefile", "--cores", cores, "--use-conda", "--nolock", "--restart-times", "3"],stderr=open(hc3_stderr,"w"))
    check["hc3"] = {"code" : hc3, "stderr" : hc3_stderr}
    stop = datetime.now()
    stop_time = stop.strftime("%H:%M")
    print("Haplotype part 3")


    elapsed_time(stop_time, start_time)


    print("Log file creation ... ")
    log = subprocess.call(["python", "/home/Utils/log.py", "-n", nameRun])
    subprocess.call(["find", "/home/", "-type", "d", "-name", ".snakemake", "-exec", "rm", "-rf", "{}", ";"], stderr=subprocess.DEVNULL)

    if os.path.isfile("/home/version/new_version.txt"):
        subprocess.call(["mv", "/home/version/new_version.txt", "/home/OutputFiles/Log/"])
    
    check_process_failed(check, "/home/OutputFiles/Log/error.txt")

    subprocess.call(["chmod", "-R", "a+rw", "/home/OutputFiles/"])
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run exome pipeline")
    parser.add_argument("-configfile", "-f", help="Configfile containing parameters for the pipeline tools",type=str)
    parser.add_argument("-cores", "-c", help='Number of cores used by snakemake', type=str)
    parser.add_argument("-nameRun", "-n", help='Name of the run', type=str)
    args = parser.parse_args()
    run_pipeline(args.configfile, args.cores, args.nameRun)
