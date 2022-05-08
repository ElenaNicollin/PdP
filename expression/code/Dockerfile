FROM ubuntu:18.04
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"

ENV DEBIAN_FRONTEND noninteractive


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


RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh

SHELL [ "/bin/bash", "-c" ]

RUN /root/miniconda3/bin/conda install -c conda-forge mamba && \
    /root/miniconda3/bin/conda update -n base -c defaults conda && \
    /root/miniconda3/bin/mamba create -y -c conda-forge -c bioconda -n snakemake snakemake && \
    /root/miniconda3/bin/conda init bash
ENV PATH /root/miniconda3/envs/snakemake/bin/:$PATH

WORKDIR /home/

RUN wget \
    http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.1.1.tar.gz && \
    tar -zxvf stringtie-2.1.1.tar.gz && \
    rm -rf stringtie-2.1.1.tar.gz && \
    cd stringtie-2.1.1 && \
    make release && \
    mv /home/stringtie*/ /home/StringTie/
ENV PATH="/home/StringTie/:${PATH}"




COPY pipeline.py prepDE.py plots.R /home/Utils/
COPY assembly.smk /home/Assembly/
COPY plots.smk /home/Plotting/

RUN mkdir /home/Log/ && mkdir /home/Config/

RUN for file in $(find /home/ -name "*.yaml"); do if ! [ $(basename $file) == config.yaml ]; then path=$(echo $file | grep -o ".*/"); mv $file $path/config.yaml; fi; done




## INSTALLATION DE R : NON FONCTIONNEL (ne parvient pas à installer DESeq2)
RUN apt-get update \
    && apt-get install -y \
    && apt-get install -y --no-install-recommends \
    littler \
    r-base \
    r-base-dev \
    r-recommended \
    && ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
    && ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
    && ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
    && install.r docopt \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
    && rm -rf /var/lib/apt/lists/*






COPY install_packages.R /tmp/install_packages.R 
RUN Rscript /tmp/install_packages.R 

CMD ["bash"]