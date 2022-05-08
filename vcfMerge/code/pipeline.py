import subprocess
import glob
import re
from urllib.request import urlopen, Request
#import argparse

def read(path):
    return open(str(path),'r').readlines()

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

def run_pipeline():
    #load(path)
    check={}

    print("File configuration loaded ...")
    download_html("https://snakemake-wrappers.readthedocs.io/en/0.61.0/wrappers/bcftools/merge.html", "/home/Log/merge.html") 

    print("Merging VCF files...")
    merging_stderr = "/home/Log/merging.log"   
    merging = subprocess.call(["snakemake","--snakefile","/home/Merge/merge.smk","--cores","2","--use-conda"], stderr=open(merging_stderr,"w"))
    check["merging"] = {"code" : merging, "stderr" : merging_stderr}

    print("Sorting into excel files...")
    formatting_stderr = "/home/Log/formatting.log"
    formatting = subprocess.call(["snakemake","--snakefile","/home/Formatting/formatting.smk","--cores","2","--use-conda"], stderr=open(formatting_stderr,"w"))
    check["formatting"] = {"code" : formatting, "stderr" : formatting_stderr}


if __name__ == "__main__":
    """
    parser = argparse.ArgumentParser(description="Run merge pipeline")
    parser.add_argument("-configfile", "-f", help="Configfile containing parameters for the pipeline tools",type=str)
    parser.add_argument("-cores", "-c", help='Number of cores used by snakemake', type=str)
    parser.add_argument("-nameRun", "-n", help='Name of the run', type=str)
    args = parser.parse_args()
    run_pipeline(args.configfile, args.cores, args.nameRun)
    """
    run_pipeline()