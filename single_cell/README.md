# 单细胞相关学习笔记
=====================

学习文档
+++++++++++++++++++++

:download:`单细胞测序工作流程_关键步骤和注意事项.pdf<单细胞测序工作流程_关键步骤和注意事项.pdf>`

`hg19_gtf <https://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/genes/>`_

`hg38_gtf <https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes)>`_

`10x测序文库学习链接 <https://teichlab.github.io/scg_lib_structs/methods_html/10xChromium3.html>`_

测序深度(10X)
+++++++++++++++++++++++++

::

    Gene Expression                                     20,000 read pairs/ cell
    Immune profiling (VDJ)                              5,000 read pairs/ targeted cell
    Gene Expression with Feature Barcoding technology   Minimum 5,000 read pairs/cell
    ATACSeq                                             25,000 read pairs per nucleus (50,000 individual reads. 25,000 from R1, 25,000 from R2
    CNV                                                 750,000 read pairs per cell (for human) enables accurate detection of 2 Mb events per single cell


商业化两平台比较 BD Rhapsody vs 10x Genomics Chromium
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

.. image::
    10x_vs_BD.png
    :height: 700px
    :width: 1000px

:download:`2020-The Comparison of Two Single-cell Sequencing Platforms-BD Rhapsody and 10x Genomics Chromium.pdf <2020-The Comparison of Two Single-cell Sequencing Platforms-BD Rhapsody and 10x Genomics Chromium.pdf>`


降维方法
+++++++++++++++++++++++++++++++++++++++++++++
t-SNE与UMAP

UMAP计算速度快，适用于大细胞数量的样本

生信分析参考
+++++++++++++++++++++++++++++++++++++++++++++

`2018-BD Single Cell Genomics Bioinformatics Handbook.pdf <2018-BD Single Cell Genomics Bioinformatics Handbook.pdf>`

`2019-Single-Cell RNA-seq Introduction to Bioinformatics Analysis.pdf <2019-Single-Cell RNA-seq Introduction to Bioinformatics Analysis.pdf>`
