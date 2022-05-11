FROM ubuntu:18.04
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"

RUN apt-get update && apt-get install -y wget \
    -y default-jre \
    -y curl \
    -y unzip \
    -y tabix \
    -y python-pip \
    -y zlib1g-dev \
    -y libbz2-dev \
    -y liblzma-dev \
    -y libxml2-dev \
    -y libcurl4-openssl-dev \ 
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/samtools/bcftools/releases/download/1.10.2/bcftools-1.10.2.tar.bz2 && \
    bzip2 -dc *.tar.bz2 | tar xvf - && \
    cd bcftools-1.10.2/ && \
    ./configure --prefix /home/bcf/ && \
    make && \
    make install
ENV PATH="/home/bcf/bin:${PATH}"


RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh

SHELL [ "/bin/bash", "-c" ]

RUN conda install -c conda-forge mamba && \
    conda update -n base -c defaults conda && \
    mamba create -y -c conda-forge -c bioconda -n snakemake snakemake && \
    conda init bash
ENV PATH /root/miniconda3/envs/snakemake/bin/:$PATH

RUN pip install pyyaml matplotlib numpy 
 
WORKDIR /home/

COPY gatk.sh /home/

RUN wget -O gatk.zip \
    https://github.com/broadinstitute/gatk/releases/download/4.1.9.0/gatk-4.1.9.0.zip && \
    unzip gatk.zip && \
    rm gatk.zip && \
    mv /home/gatk*/ /home/gatk/ && \
    mkdir /home/version/

RUN wget -O gtf.gz \
    ftp://ftp.ensembl.org/pub/release-102/gtf/homo_sapiens/Homo_sapiens.GRCh38.102.gtf.gz && \
    gunzip gtf.gz && \
    mv gtf human.gtf

RUN ./gatk.sh https://github.com/broadinstitute/gatk/releases/latest/

RUN wget -O qualimap.zip \
    https://bitbucket.org/kokonech/qualimap/downloads/qualimap_v2.2.1.zip && \
    unzip qualimap.zip && \
    rm qualimap.zip && \
    mv /home/qualimap*/ /home/Qualimap/

COPY pipeline.py log.py function.sh fastq_reads.sh splitData.py plot.py metrics.py coverage.py gvcf.py genotypeGVCF.py selectVariants.py index.py individual.py /home/Utils/
COPY pre_processing.smk /home/Pre_processing/
COPY fastqc.smk /home/FastQC/
COPY trimming.smk /home/Trimming/
COPY trimming_illumina.smk /home/Trimming/Illumina/
COPY trimming_takara.smk /home/Trimming/Takara/
COPY star.smk /home/Rules/Mapping/STAR/
COPY star.yaml /home/Rules/Mapping/STAR/
COPY hc.smk /home/Rules/VariantCalling/HaplotypeCaller/Part1/
COPY hc2.smk /home/Rules/VariantCalling/HaplotypeCaller/Part2/
COPY hc3.smk /home/Rules/VariantCalling/HaplotypeCaller/Part3/
COPY hc.yaml /home/Rules/VariantCalling/HaplotypeCaller/
COPY hs_metrics.smk /home/Rules/HsMetrics/Part1/
COPY hs_metrics2.smk /home/Rules/HsMetrics/Part2/
COPY global.smk /home/Global/

RUN mkdir /home/Config/ && mkdir /home/SampleSheet/ && mkdir /home/Bed/ && mkdir /home/Log/

RUN for file in $(find /home/ -name "*.smk"); do if ! [ $(basename $file) == Snakefile ]; then path=$(echo $file | grep -o ".*/"); mv $file $path/Snakefile; fi; done
RUN for file in $(find /home/ -name "*.yaml"); do if ! [ $(basename $file) == config.yaml ]; then path=$(echo $file | grep -o ".*/"); mv $file $path/config.yaml; fi; done
