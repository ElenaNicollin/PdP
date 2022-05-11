import pandas as pd
import os

#Permet de concatener les fichiers de markduplicates et collecthsmetrics pour avoir un seul df pour l'ensemble du run et 
#calculer la moyenne. Le fichier concatener permet ensuite de tracer les graphes.

def concatenateMetrics(inputFiles, outputFile):
    df = pd.read_table(inputFiles[0], delimiter="\t", decimal=",")
    df.insert(0, column="Sample", value=os.path.basename(inputFiles[0].split(".")[0]))
    df.to_csv(outputFile, mode='a', header=True, sep = ";", index=False)

    for f in inputFiles[1:]:
        df = pd.read_table(f, delimiter="\t", decimal=",")
        sample = os.path.basename(f).split('.')[0]
        df.insert(0, column="Sample", value=os.path.basename(f.split(".")[0]))
        df.to_csv(outputFile, mode='a', header=False, sep=";", index=False)

    df = pd.read_table(outputFile, delimiter=";", decimal=".")
    means = df.iloc[:,2:].mean().round(2)
    df_mean = means.to_frame()
    df_mean2 = df_mean.transpose()
    df_mean2.insert(0, column="Sample", value="Moyenne")
    df_mean2.insert(1, column="", value="")
    df_mean2.to_csv(outputFile, mode='a', header=False, sep=";", index=False)

if __name__ == "__main__":
    concatenateMetrics(list(snakemake.input), snakemake.output.meanMetrics)
