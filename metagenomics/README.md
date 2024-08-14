# User guide


[step1: prepare reference](./reference/README.rst)

step2: download docker images
```{.cs}
docker pull fanyucai1/meta
```

step3: run script



docker run -e PATH=/opt/conda/envs/meta/bin:$PATH \
-v /staging/fanyucai/metagenomics/script/:/script/ \
-v /staging/fanyucai/metagenomics/test_data/:/raw_data/ \
-v /staging/fanyucai/metagenomics/ref/:/ref/ \
-v /staging/fanyucai/metagenomics/out_dir/:/outdir/ meta \
python3 script/filter_host.py \
-p1 /raw_data/SRR13439800.1_1.fastq \
-p2 /raw_data/SRR13439800.1_2.fastq \
-i /ref/bowtie2_human/chm13v2.0 -o /outdir/ -p test



