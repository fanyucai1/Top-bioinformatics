FROM alpine:latest
RUN apk update && \
    apk add --no-cache bash && mkdir -p /lib64/ && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk && apk add --no-cache --force-overwrite glibc-2.35-r1.apk && rm glibc-2.35-r1.apk && ln -s /usr/glibc-compat/lib/* /lib64/ && \
    cd /opt/ && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && bash /opt/Miniconda3-latest-Linux-x86_64.sh -f -b -p /opt/conda/ && rm -rf /opt/Miniconda3-latest-Linux-x86_64.sh /var/cache/apk/* &&  \
    /opt/conda/bin/conda install conda-forge::mamba && \
    /opt/conda/bin/mamba create --name rgi --channel conda-forge --channel bioconda --channel defaults rgi && \
    /opt/conda/bin/mamba create --name metaphlan --channel conda-forge --channel bioconda --channel defaults metaphlan && \
    /opt/conda/bin/mamba create --name prokka --channel conda-forge --channel bioconda --channel defaults prokka && \
    /opt/conda/bin/mamba create --name meta --channel conda-forge --channel bioconda --channel defaults covtobed metabat2 fastqtk  \
    bbmap quast kraken2 krakentools krona minimap2 megahit cd-hit seqtk spades ivar=1.3 freebayes resfinder fastp megan bcftools prinseq &&  \
    /opt/conda/bin/conda clean -a -y && mkdir -p /script/ /raw_data/ /ref/ /outdir/