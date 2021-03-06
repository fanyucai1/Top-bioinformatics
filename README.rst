生信资源
======================

`菜鸟教程:https://www.runoob.com <https://www.runoob.com>`_

`R语言学习资源:Cookbook for R <http://www.cookbook-r.com>`_

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

`CentOS Repositories:https://centos.pkgs.org <https://centos.pkgs.org>`_



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
    RUN cd /software/python3 && tar xvf Python-3.10.5.tgz && cd Python-3.10.5 && ./configure --prefix=/software/python3/Python-v3.10.5 --with-openssl=/usr/local/openssl && make -j20 && make install

