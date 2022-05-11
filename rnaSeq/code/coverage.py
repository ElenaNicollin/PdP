import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.colors import ListedColormap, LinearSegmentedColormap, rgb2hex

#Permet de tracer les graphes de metriques issus de CollectHSMetrics. Ce script trace le graphe avec le degrade vert pour avoir le nombre
#de base a une couverture specifique.

def createBarPlot(df, output):
    data = pd.read_table(df, delimiter=";", decimal=".")
    coverage = ["PCT_TARGET_BASES_100X", "PCT_TARGET_BASES_50X", "PCT_TARGET_BASES_40X", "PCT_TARGET_BASES_30X", "PCT_TARGET_BASES_20X", "PCT_TARGET_BASES_10X", "PCT_TARGET_BASES_2X", "PCT_TARGET_BASES_1X"]
    bases = "ON_TARGET_BASES"
    values = []
    samples = data["Sample"].tolist()
    samples.pop()
    coverage_graph = []

    for index, row in data.iterrows():
        if row["Sample"] != "Moyenne":
            bases = []
            targetbases = row["ON_TARGET_BASES"]
            for i in range(len(coverage)):
                if i == 0:
                    bases.append(targetbases * row[coverage[i]])
                if i+1 != len(coverage):
                    bases.append(targetbases * row[coverage[i+1]] - targetbases * row[coverage[i]])
            values.append(bases)

    barWidth = 1 / len(samples)
    interval = [ x + barWidth for x in range(len(values[0]))]
    xticks = interval.copy()
    plt.figure(figsize=(20,15))

    color = []
    cmap = cm.get_cmap('Greens', 17)
    for i in range(cmap.N):
        rgb = cmap(i)[:3] # will return rgba, we take only first 3 so we get rgb
        color.append(rgb)

    for cov in coverage:
        coverage_graph.append(cov.split("_")[-1])

    for i in range(len(values)):
        colorIndice = -i - 1 
        plt.bar(interval, values[i], width=barWidth, label=samples[i], color=color[colorIndice], alpha=1, linewidth=0)
        interval = [ x + barWidth for x in interval ]
        plt.xlabel('Couverture', fontweight='bold')
        plt.ylabel('Nombre de bases', fontweight='bold')
    plt.xticks(xticks, coverage_graph)
    plt.title("Nombre de bases sur les régions cibles en fonction de la couverture", y=1.08)
    plt.legend()
    plt.tight_layout()
    plt.savefig(snakemake.output.coveragePlot)

if __name__ == "__main__":
    createBarPlot(snakemake.input.meanMetrics, snakemake.output.coveragePlot)
