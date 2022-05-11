import glob

configfile: "/home/Utils/config.yaml"

rule all:
    input:
        "/home/OutputFiles/QC/7-PicardHSMetrics/PicardHSMetricsMean_metrics.tsv",
        "/home/OutputFiles/QC/7-PicardHSMetrics/PicardHSMetricsMean_barplot.pdf",
        "/home/OutputFiles/QC/7-PicardHSMetrics/CoverageBarplot.pdf",
        "/home/OutputFiles/QC/4-DuplicatesMetrics/DuplicateMetricsMean.tsv"

rule metrics:
    input:
        glob.glob("/home/tmp/metrics/HS/*")
    output:
        meanMetrics = "/home/OutputFiles/QC/7-PicardHSMetrics/PicardHSMetricsMean_metrics.tsv"
    script:
        "/home/Utils/metrics.py"

rule histogram:
    input:
        meanMetrics = "/home/OutputFiles/QC/7-PicardHSMetrics/PicardHSMetricsMean_metrics.tsv"
    output:
        meanPlot = "/home/OutputFiles/QC/7-PicardHSMetrics/PicardHSMetricsMean_barplot.pdf"
    script:
        "/home/Utils/plot.py"

rule barplotCoverage:
    input:
        meanMetrics = "/home/OutputFiles/QC/7-PicardHSMetrics/PicardHSMetricsMean_metrics.tsv"
    output:
        coveragePlot = "/home/OutputFiles/QC/7-PicardHSMetrics/CoverageBarplot.pdf"
    script:
        "/home/Utils/coverage.py"

rule MDmetrics:
    input:
        glob.glob("/home/tmp/metrics/MD/*")
    output:
        meanMetrics = "/home/OutputFiles/QC/4-DuplicatesMetrics/DuplicateMetricsMean.tsv"
    script:
        "/home/Utils/metrics.py"
