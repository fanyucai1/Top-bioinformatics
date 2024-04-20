# R软件包安装

方法一:
```{.cs}
options(BioC_mirror="http://mirrors.ustc.edu.cn/bioc/")
source("http://www.bioconductor.org/biocLite.R")
biocLite("GDCRNATools")

Rscript -e "BiocManager::install(\"ComplexHeatmap\")"
```

方法二：
```{.cs}
Rscript -e "install.packages(c(\"BiocManager\"))"
```

方法三：
```{.cs}
R CMD INSTALL EnrichmentBrowser_2.4.5_CA_edit.tar.gz
```
