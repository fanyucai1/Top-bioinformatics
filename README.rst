生信资源
======================

`菜鸟教程:https://www.runoob.com <https://www.runoob.com>`_

`R语言学习资源:Cookbook for R <http://www.cookbook-r.com>`_

`R语言学习资源:tidyverse <https://www.tidyverse.org/>`_

`python学习在线资源:Cookbook for python <http://python3-cookbook.readthedocs.io/zh_CN/latest/index.html>`_

`文献下载网站:GeenMedical <https://www.geenmedical.com>`_

`书籍下载：鸠摩搜索 <https://www.jiumodiary.com>`_

`在线Markdown简单实用说明:Markdown <https://commonmark.org/help/>`_

`变异位点命名:Mutalyzer <https://mutalyzer.nl>`_

`变异位点命名:VariantValidator <https://variantvalidator.org>`_

`ACMG中文指南 <http://acmg.cbgc.org.cn/doku.php?id=start>`_

`Memorial Sloan Kettering Cancer Center (MSK)的精准肿瘤学知识库 OncoKB: A Precision Oncology Knowledge Base <https://www.oncokb.org/>`_

`medicalxpress <https://medicalxpress.com/>`_

`genomeweb <https://www.genomeweb.com/>`_

`测序中国 <https://www.seqchina.cn/>`_

`github中文排行榜 <https://github.com/kon9chunkit/GitHub-Chinese-Top-Charts>`_

`Pycharm软件激活 <https://www.ajihuo.com/>`_

命名标准化
=====================

`HGNC:https://www.genenames.org <https://www.genenames.org>`_

`GeneCards:https://www.genecards.org <GeneCards>`_

`变异位点命名:Mutalyzer <https://mutalyzer.nl>`_

`变异位点命名:VariantValidator <https://variantvalidator.org>`_

序列重比对
==================
`abra2 <https://github.com/mozack/abra2>`_

UCSC资源
===================

`For hg19:http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/latest/ <http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/latest/>`_

`For hg38:http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/latest/ <http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/latest/>`_

`https://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/ <https://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/>`_

Metagenomic
======================

`Kraken Wiki:https://github.com/DerrickWood/kraken2/wiki <https://github.com/DerrickWood/kraken2/wiki>`_

`Kraken index: https://benlangmead.github.io/aws-indexes/k2 <https://benlangmead.github.io/aws-indexes/k2>`_

`FDA-ARGOS is a database with public quality-controlled reference genomes for diagnostic use and regulatory science <https://www.ncbi.nlm.nih.gov/bioproject/231221>`_

Linux
===============

`Packages for Linux and Unix:https://pkgs.org/ <https://pkgs.org/>`_

文档转化
=================

`Pandoc a universal document converter <https://pandoc.org/index.html>`_

安装python3
====================
::

    mkdir -p /usr/local/openssl/
    cd /software/ && tar -zxvf openssl-1.1.1m.tar.gz
    cd /software/openssl-1.1.1m/ && ./config --prefix=/usr/local/openssl
    make -j20
    make install
    mv /usr/bin/openssl /usr/bin/openssl.old
    mv /usr/lib64/openssl /usr/lib64/openssl.old
    ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
    ln -s /usr/local/openssl/include/openssl /usr/include/openssl
    echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
    ldconfig -v
    cd /software/python3 && tar xvf Python-3.10.5.tgz && cd Python-3.10.5 && ./configure --prefix=/software/python3/Python-v3.10.5 --with-openssl=/usr/local/openssl && make -j20 && make install

关于liftover
===================

**UCSC chain files**

    Chain files from hs1 (T2T-CHM13) to hg38/hg19/mm10/mm9 (ore vice versa): https://hgdownload.soe.ucsc.edu/goldenPath/hs1/liftOver/

    Chain files from hg38 (GRCh38) to hg19 and all other organisms: http://hgdownload.soe.ucsc.edu/goldenPath/hg38/liftOver/

    Chain File from hg19 (GRCh37) to hg17/hg18/hg38 and all other organisms: http://hgdownload.soe.ucsc.edu/goldenPath/hg19/liftOver/

**Ensembl chain files**

    Human to Human: http://ftp.ensembl.org/pub/assembly_mapping/homo_sapiens/
**Tools**

CrossMap:https://crossmap.sourceforge.net/

picard:https://gatk.broadinstitute.org/hc/en-us/articles/360037060932-LiftoverVcf-Picard- ::

    java -jar picard.jar LiftoverVcf \\
     I=input.vcf \\
     O=lifted_over.vcf \\
     CHAIN=b37tohg38.chain \\
     REJECT=rejected_variants.vcf \\
     R=reference_sequence.fasta
     其中The reference sequence (fasta) for the TARGET genome build

Genomic Data Commons (GDC) Data User’s Guide_bioinformatic
==========================================================================

`Genomic Data Commons (GDC) Data User’s Guide_bioinformatic.pdf <https://docs.gdc.cancer.gov/Data_Portal/PDF/Data_Portal_UG.pdf>`_


GATK资源下载
====================

参考链接 https://gatk.broadinstitute.org/hc/en-us/articles/360035890811-Resource-bundle

genomics-public-data
+++++++++++++++++++++++++++
https://console.cloud.google.com/storage/browser/genomics-public-data

Description: The buckets contain an assortment of reference, resource, and sample test data which can be used in GATK workflows.

gcp-public-data--broad-references
+++++++++++++++++++++++++++++++++++++
https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references

Description: This is the Broad's public hg38 and b37 reference and resource data.Example workspaces include:**Whole-Genome-Analysis-Pipeline,GATK4-Germline-Preprocessing-VariantCalling-JointCalling**

gatk-legacy-bundles
+++++++++++++++++++++++++++++++++++
https://console.cloud.google.com/storage/browser/gatk-legacy-bundles

Description: Broad public legacy b37 and hg19 reference and resource data.

broad-public-datasets
+++++++++++++++++++++++++++++++++++
https://console.cloud.google.com/storage/browser/broad-public-datasets

Description: Stores public test data, often used to test workflows. For example, it contains NA12878 CRAM, gVCF, and unmapped BAM files.

gatk-best-practices
+++++++++++++++++++++++++++++++++++
https://console.cloud.google.com/storage/browser/gatk-best-practices

Description: Stores GATK workflow specific plumbing, reference, and resources data. Example workspaces include:**Somatic-SNVs-Indels-GATK4**

gatk-test-data
+++++++++++++++++++++++++++++++++++
https://console.cloud.google.com/storage/browser/gatk-test-data

Description: Additional public test data focusing on smaller data sets. For example, whole genome BAM, FASTQ, gVCF, VCF, etc. Example Workspaces include:**Somatic-CNVs-GATK4**

人类参考基因组说明Human genome reference builds
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
https://gatk.broadinstitute.org/hc/en-us/articles/360035890951-Human-genome-reference-builds-GRCh38-or-hg38-b37-hg19

Genome in a Bottle Consortium Genomes
============================================================
`相关资源链接：https://github.com/genome-in-a-bottle <https://github.com/genome-in-a-bottle>`_

.. image:: GIAB.png

GWAS研究资源
=========================
`GWASLab–GWAS实验室 <https://gwaslab.org/>`_

NGS数据模拟: InSilicoSeq
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

MAC
===============
关于git报错
::

    git config --global --unset http.proxy
    git config --global --unset https.proxy

安装brew
::

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"



设置brew镜像安装软件
::

    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    brew update
    brew install git

vim 基本命令查找和替换
=====================================
(命令模式)移动光标
+++++++++++++++++++++++++++
在vim界面，命令模式下光标移动方法::

    :set  nu     //显示行号
    :set nonu    //取消显示行号
    n+        //向下跳n行
    n-         //向上跳n行
    nG        //跳到行号为n的行
    G           //跳至文件的底部
    g         //跳转到文件头部


(插入模式)编辑模式
+++++++++++++++++++++++++++
以下按键进入编辑插入模式::

    a      //在当前光标位置的右边添加文本
    i       //在当前光标位置的左边添加文本
    A     //在当前行的末尾位置添加文本
    I      //在当前行的开始处添加文本(非空字符的行首)
    O     //在当前行的上面新建一行
    o     //在当前行的下面新建一行
    R    //替换(覆盖)当前光标位置及后面的若干文本
    J    //合并光标所在行及下一行为一行(依然在命令模式)

(命令模式)删除和复制
+++++++++++++++++++++++++++
在vim中, 除了在编辑模式下修改文件，命令模式的时候可以删除和复制::

    x         //删除当前字符
    nx         //删除从光标开始的n个字符
    dd       //删除当前行
    ndd      //向下删除当前行在内的n行
    u        //撤销上一步操作
    U        //撤销对当前行的所有操作
    yy       //将当前行复制到缓存区，也可以用 "ayy 复制，"a 为缓冲区，a也可以替换为a到z的任意字母，可以完成多个复制任务。
    nyy      //将当前行向下n行复制到缓冲区，也可以用 "anyy 复制，"a 为缓冲区，a也可以替换为a到z的任意字母，可以完成多个复制任务。
    yw       //复制从光标开始到词尾的字符。
    nyw      //复制从光标开始的n个单词。
    y^       //复制从光标到行首的内容。  VPS侦探
    y$       //复制从光标到行尾的内容。
    p        //粘贴剪切板里的内容在光标后，如果使用了前面的自定义缓冲区，建议使用"ap 进行粘贴。
    P        //粘贴剪切板里的内容在光标前，如果使用了前面的自定义缓冲区，建议使用"aP 进行粘贴。


(命令模式)搜索和替换
+++++++++++++++++++++++++++
命令模式下(esc退出插入模式)::

    /keyword     //向光标下搜索keyword字符串，keyword可以是正则表达式
    ?keyword     //向光标上搜索keyword字符串
    n           //向下搜索前一个搜素动作
    N         //向上搜索前一个搜索动作

    *(#)      //当光标停留在某个单词上时, 输入这条命令表示查找与该单词匹配的下(上)一个单词. 同样, 再输入 n 查找下一个匹配处, 输入 N 反方向查找.

    g*(g#)        //此命令与上条命令相似, 只不过它不完全匹配光标所在处的单词, 而是匹配包含该单词的所有字符串.

    :s/old/new      //用new替换行中首次出现的old
    :s/old/new/g         //用new替换行中所有的old
    :n,m s/old/new/g     //用new替换从n到m行里所有的old
    :%s/old/new/g      //用new替换当前文件里所有的old

somatic
======================
1.  AACR Project GENIE

    .. image:: Large_GENIE_logo.jpg

    `AACR Project GENIE:https://www.synapse.org/#!Synapse:syn7222066/wiki/405659 <https://www.synapse.org/#!Synapse:syn7222066/wiki/405659>`_

    `Suehnholz S P, Nissan M H, Zhang H, et al. Quantifying the Expanding Landscape of Clinical Actionability for Patients with Cancer[J]. Cancer Discovery, 2023. <https://aacrjournals.org/cancerdiscovery/article/doi/10.1158/2159-8290.CD-23-0467/729589>`_

2.  `GDC DNA-Seq analysis pipeline <https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/DNA_Seq_Variant_Calling_Pipeline/>`_ ::

    DNA-Seq analysis is implemented across six main procedures

        Genome Alignment

        Alignment Co-Cleaning

        Somatic Variant Calling

        Variant Annotation

        Mutation Aggregation

        Aggregated Mutation Masking

3.  `Menzel M, Ossowski S, Kral S, et al. Multicentric pilot study to standardize clinical whole exome sequencing (WES) for cancer patients[J]. NPJ Precision Oncology, 2023, 7(1): 106. <https://www.nature.com/articles/s41698-023-00457-x>`_

    .. image:: protocols.png

4.  `Cortés-Ciriano I, Gulhan D C, Lee J J K, et al. Computational analysis of cancer genome sequencing data[J]. Nature Reviews Genetics, 2022, 23(5): 298-314. <https://www.nature.com/articles/s41576-021-00431-y>`_

5.  1000 Genomes Project

    Details of the analyses and the pipeline can be found at https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/20190405_NYGC_b38_pipeline_description.pdf

other
=================
1. Illustration of relationship between sequencing depth and variant call confidence as a function of VAF.

    .. image:: depth_VAF.jpg

2.  Example of a valid VCF file with header and a few variant site records.

    .. image:: VCF.jpg

`Larson N B, Oberg A L, Adjei A A, et al. A clinician’s guide to bioinformatics for next-generation sequencing[J]. Journal of Thoracic Oncology, 2023, 18(2): 143-157. <https://www.sciencedirect.com/science/article/pii/S1556086422019086>`_


Online Knowledge Bases to Aid Clinical Decision Making
====================================================================
`My Cancer Genome:www.mycancergenome.org <www.mycancergenome.org>`_

`JAX Clinical Knowledgebase:https://ckb.jax.org <https://ckb.jax.org>`_

`Clinical Interpretation of Variants in Cancer:https://civic.genome.wustl.edu> <https://civic.genome.wustl.edu>`_

`Oncology Knowledge Base:https://oncokb.org <https://oncokb.org>`_

`Clinical Genome:https://clinicalgenome.org <https://clinicalgenome.org>`_

1.  For hot spot testing, coverage of at least 100–300X is recommended.

2.  Example of Hierarchy of Evidence of Genomic Alterations

    .. image:: Hierarchy.jpeg

`Schwartzberg L, Kim E S, Liu D, et al. Precision oncology: who, how, what, when, and when not?[J]. American Society of Clinical Oncology Educational Book, 2017, 37: 160-169. <https://ascopubs.org/doi/abs/10.1200/EDBK_174176>`_

