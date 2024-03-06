# NGS数据模拟

## InSilicoSeq
```{.cs}
docker pull hadrieng/insilicoseq:latest

Document user guide: https://insilicoseq.readthedocs.io/en/latest/iss/generate.html

command ::

    docker run -v /staging/explify_china/test_data/:/mnt/data -it \
    --rm hadrieng/insilicoseq iss generate --genomes /mnt/data/combine.fna \
    -m NovaSeq -z -o /mnt/data/reads --cpus 50 --coverage_file /mnt/data/coverage.txt

**coverage.txt** ::

    BA.1.1 2100
    BA.5.1 600
    BA.5.2.48 450
    BF.7.14 300
    B.1.617.2 150

**parameter** ::

    InSilicoSeq comes with 3 error models:

    MiSeq	300 bp
    HiSeq	125 bp
    NovaSeq	150 bp
```

[Duncavage E J, Coleman J F, de Baca M E, et al. Recommendations for the use of in silico approaches for next-generation sequencing bioinformatic pipeline validation: a joint report of the Association for Molecular Pathology, Association for Pathology Informatics, and College of American Pathologists[J]. The Journal of molecular diagnostics, 2023, 25(1): 3-16.](https://www.sciencedirect.com/science/article/pii/S1525157822002872)