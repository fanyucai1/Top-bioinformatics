# User guide

step1: download docker images
```{.cs}
docker pull fanyucai1/meta
docker tag fanyucai1/meta meta
```

step2: Download database
```{.cs}
mkdir -p /ref/ 
################host bowtie2 index(https://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
mkdir -p /ref/bowtie2
cd /ref/bowtie2
wget https://genome-idx.s3.amazonaws.com/bt/grch38_1kgmaj_snvindels_bt2.zip #https://github.com/BenLangmead/bowtie-majref   GRCh38 + major SNP-and-indels
unzip grch38_1kgmaj_snvindels_bt2.zip

################kraken2 database(https://benlangmead.github.io/aws-indexes/k2)
mkdir -p /ref/kraken2/
cd /ref/kraken2/
wget https://genome-idx.s3.amazonaws.com/kraken/k2_pluspfp_20240605.tar.gz #Standard plus Refeq protozoa, fungi & plant
tar xzvf k2_standard_20240605.tar.gz

################CARD Reference Data(https://github.com/arpcard/rgi)
mkdir -p /ref/card/
cd /ref/card/
wget https://card.mcmaster.ca/latest/data && tar -xvf data ./card.json && rm -rf data
wget -O wildcard_data.tar.bz2 https://card.mcmaster.ca/latest/variants
mkdir -p wildcard
tar -xjf wildcard_data.tar.bz2 -C wildcard
gunzip wildcard/*.gz
docker run -v /ref/card:/ref/ meta sh -c 'cd /ref/ && /opt/conda/envs/rgi/bin/rgi card_annotation -i /ref/card.json'
# get version info from https://card.mcmaster.ca/download
docker run -v /ref/card:/ref/ meta sh -c 'cd /ref/ && /opt/conda/envs/rgi/bin/rgi wildcard_annotation -i wildcard --card_json /ref/card.json -v 4.0.2'

################staramr(https://github.com/phac-nml/staramr)
cd /ref/
docker run -v /staging/fanyucai/metagenomics/ref/:/ref/ meta staramr db build --dir /ref/staramr/

################CheckM2_database
docker run -v /staging/fanyucai/metagenomics/ref:/ref meta /opt/conda/envs/checkm2/bin/checkm2 database --download --path /ref/


```


