import glob
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#Cree les graphes total reads, mean target coverage, pct target bases 30X et fold 80.

def createAvgPlot(inputFile, outputFile):
    keyword = ["TOTAL_READS", "MEAN_TARGET_COVERAGE", "PCT_TARGET_BASES_30X", "FOLD_80_BASE_PENALTY"]
    values = {}
    df = pd.read_table(inputFile, delimiter=";", decimal=".")
    for key in keyword:
        values[key] = df[key].tolist()
    sample = df["Sample"].tolist()

    fig, axs = plt.subplots(len(values),1,figsize=(10,15))
    
    i = 0
    for key in values.keys():
        createBarPlot(sample, values, key, i, axs)
        i += 1
    
    fig.tight_layout()
    fig.savefig(outputFile)

def createBarPlot(sample, dict, value, indice, axs):
    color = ["orange", "forestgreen", "firebrick", "steelblue"]
    barlist = axs[indice].bar(range(len(sample)), dict[value], color = color[indice], tick_label = sample, capsize=2, width=0.4)
    barlist[len(sample)-1].set_color('black')
    axs[indice].set_title(" ".join(value.split("_")))
    

if __name__ == "__main__":
    createAvgPlot(snakemake.input.meanMetrics, snakemake.output.meanPlot)