FROM alpine:latest
RUN apk add --no-cache bash perl perl-dev python3 python3-dev py3-numpy gzip unzip tar openjdk11 && mkdir -p /lib64/ && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk &&  \
    apk add --no-cache --force-overwrite glibc-2.35-r1.apk && rm glibc-2.35-r1.apk && ln -s /usr/glibc-compat/lib/* /lib64/ && \
    cd /opt/ && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh &&  \
    bash /opt/Miniconda3-latest-Linux-x86_64.sh -f -b -p /opt/conda/ \
    && rm -rf /opt/Miniconda3-latest-Linux-x86_64.sh /var/cache/apk/* &&  \
    /opt/conda/bin/conda install conda-forge::mamba && \
    /opt/conda/bin/mamba create --name rgi --channel conda-forge --channel bioconda --channel defaults rgi && \
    /opt/conda/bin/mamba create --name gtdbtk --channel conda-forge --channel bioconda --channel defaults gtdbtk && \
    /opt/conda/bin/mamba install --channel conda-forge --channel bioconda --channel defaults  \
    quast minimap2 megahit cd-hit spades freebayes resfinder  \
    fastqtk seqtk bbmap fastp fastqc prinseq cutadapt multiqc trimmomatic  \
    bcftools prokka covtobed metabat2 \
    megan kraken2 krakentools krona bracken &&  \
    /opt/conda/bin/conda clean -a -y && /opt/conda/bin/mamba clean -a -y &&  \
    mkdir -p /ref/ /script/ /raw_data/ /outdir/