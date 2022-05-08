import subprocess
import glob
import re
import argparse

def read(path):
    return open(str(path),'r').readlines()

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

def load(path):
    f = open(path,"r")
    data = f.readlines()
    common = data[0:3]
    version = "0.61.0"
    common.insert(0, "version : " + version  + "\n")
    f.close()
    create_config(common, 3, data, "/home/Utils/config.yaml")

def create_config(common, start, data, path):
    config = open(path, "w")
    for line in common:
        config.write(line)
    while re.search(".* : ", data[start].strip()):
        config.write(data[start])
        start += 1
    config.close()
    return start


def run_pipeline(path, cores, nameRun):
    load(path)
    check={}

    print("File configuration loaded")

    print("StringTie : assembling transcripts...")
    assembly_stderr = "/home/Log/assembly.log"   
    assembly = subprocess.call(["snakemake","--snakefile","/home/Assembly/assembly.smk","--cores",cores,"--use-conda"], stderr=open(assembly_stderr,"w"))
    check["assembly"] = {"code" : assembly, "stderr" : assembly_stderr}
    
    print("R : creating plots...")
    plotting_stderr = "/home/Log/plotting.log"   
    plotting = subprocess.call(["snakemake","--snakefile","/home/Plotting/plots.smk","--cores",cores,"--use-conda"], stderr=open(plotting_stderr,"w"))
    check["plotting"] = {"code" : plotting, "stderr" : plotting_stderr}



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run merge pipeline")
    parser.add_argument("-configfile", "-f", help="Configfile containing parameters for the pipeline tools",type=str)
    parser.add_argument("-cores", "-c", help='Number of cores used by snakemake', type=str)
    parser.add_argument("-nameRun", "-n", help='Name of the run', type=str)
    args = parser.parse_args()
    run_pipeline(args.configfile, args.cores, args.nameRun)