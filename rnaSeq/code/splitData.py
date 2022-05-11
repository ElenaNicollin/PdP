import subprocess

#Ce script permet de split la sortie de markduplicates et collecthsmetrics pour separer les valeurs du dataframe et du graphe.

def readMetrics(input, metrics_output):
    f = open(input, "r")
    data = f.readlines()
    headers_str = subprocess.check_output(["grep", "^## [A-Z]", input]).decode("utf-8")
    headers_list = headers_str.split("\n")
    metrics_index = data.index(headers_list[0] + "\n")
    histogram_index = data.index(headers_list[1] + "\n")
    metrics = data[metrics_index+1:histogram_index]

    f.close()
    
    metricsFile = open(metrics_output, "w")
    for line in metrics:
        metricsFile.write(line)
    metricsFile.close()

if __name__ == "__main__":
    readMetrics(snakemake.input[0], snakemake.output.metrics)
