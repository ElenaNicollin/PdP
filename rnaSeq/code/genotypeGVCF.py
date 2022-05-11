import sys
import os
import tempfile
import subprocess
import glob


from time import *
from multiprocessing import *

def launchGenotypeGVCFs(java_opts, ref, db, chrom, extra, output):
    cmd_line = "/home/gatk/./gatk --java-options %s GenotypeGVCFs -R %s -V gendb://%s -L %s %s 2>&1 -O %s"%(java_opts, ref, db, chrom, extra, output)
    launchprogram(cmd_line)
    return output

def launchprogram(cmd_line):
    tmp_fd, tmp_name=tempfile.mkstemp()
    r=subprocess.call(cmd_line,stdout=tmp_fd, stderr=subprocess.STDOUT, shell=True)
    if r!=0:
        sys.stderr.write("error: {} failed\n".format(cmd_line))
        sys.exit(1)
    
    os.close(tmp_fd)
    os.unlink(tmp_name)


# Parallelisation par chromosome de l'appel des variants
t0  = time()
p   = Pool(processes = snakemake.params.threads)
_chroms = []

# Recuperation des noms des chromosomes du vcf
chromosomes = "".join(open(snakemake.input.intervals, 'r').readlines()).rstrip().split('\n')
output_basename = snakemake.output.vcf.split('.')[0]

for chrom in chromosomes:
    if not os.path.exists(output_basename + "_" + chrom + ".vcf.gz"):
        sv = p.apply_async(launchGenotypeGVCFs, args=(snakemake.params.java_opts, snakemake.input.ref, snakemake.input.db, chrom, snakemake.params.extra, output_basename + "_" + chrom + ".vcf.gz",))
        _chroms.append(sv)

# Main loop
done = False

while not done:
    change_occured = False
    remaining_chroms = []
    for sv in _chroms:
        if sv.ready:
            r = sv.get()
            change_occured = True
        else:
            remaining_chroms.append(sv)
    _chroms = remaining_chroms
    print(_chroms)
    if not change_occured:
        sleep(1)
    done = len(_chroms) == 0

p.close()
p.join()

t1 = time()
print("GenotypeGVCFs by chromosome elapse seconds:", t1-t0, "(%d hours)" % (float(t1-t0)/float(3600)))

#Ordonner les chromosomes pour avoir 1, 2, 3, etc dans le vcf
ordonnee = []

for chrom in chromosomes:
    vcf_chromosome = glob.glob(output_basename + "_" + chrom + ".vcf.gz")[0]
    ordonnee.append(vcf_chromosome)

vcfs = " ".join(ordonnee)

#Concatenation des fichiers vcf en un unique vcf
cmd_line = "bcftools concat --threads %d %s -Oz > %s"%(snakemake.params.bcftools, vcfs, snakemake.output.vcf)
launchprogram(cmd_line)

#Suppression des vcf chromosome
cmd_line = "rm %s"%(vcfs)
launchprogram(cmd_line)

#Suppresion des index vcf chromosome
cmd_line = "rm %s"%(output_basename + "*.tbi")
launchprogram(cmd_line)
