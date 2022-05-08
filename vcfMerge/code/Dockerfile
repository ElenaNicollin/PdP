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

RUN /root/miniconda3/bin/conda install -c conda-forge mamba && \
    /root/miniconda3/bin/conda update -n base -c defaults conda && \
    /root/miniconda3/bin/mamba create -y -c conda-forge -c bioconda -n snakemake snakemake && \
    /root/miniconda3/bin/conda init bash && \
    /root/miniconda3/envs/snakemake/bin/python -m pip install xlsxwriter openpyxl
ENV PATH /root/miniconda3/envs/snakemake/bin/:$PATH

WORKDIR /home/

COPY pipeline.py vcf_to_excel.py excel_split.py /home/Utils/
COPY merge.smk /home/Merge/
COPY formatting.smk /home/Formatting/

RUN mkdir /home/Log/