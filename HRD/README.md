# HRD检测方法

HRD主要病因有3种：①突变(包括胚系BRCA基因、胚系HR基因和体细胞HR基因)，②结构重排(LOH，杂合性丢失;TAI，端粒等位基因失平衡；LST，大片段迁移)，③表观遗传修饰(启动子甲基化)。

Loss of Heterozygosity杂合性缺失：1）长于15Mb，2）短于整个染色体LOH区域数量 ::

    Abkevich V, Timms K M, Hennessy B T, et al. Patterns of genomic loss of heterozygosity predict homologous recombination repair defects in epithelial ovarian cancer[J]. British journal of cancer, 2012, 107(10): 1776-1782.

Large Scale Transitions (LST)大片端迁移：过滤掉小于3 Mb的区域后，超过10 Mb的区域之间的断点数量 ::

    Popova, T., E. Manie, G. Rieunier, V. Caux-Moncoutier, C. Tirapo, T. Dubois, O. Delattre, et al. 2012. “Ploidy and large-scale genomic instability consistently identify basal-like breast carcinomas with BRCA1/2 inactivation.” Cancer Res. 72 (21): 5454–62.

Telomeric Allelic Imbalances（TAI）端粒等位基因不平衡：1）延长至亚端粒之一；2）不穿过着丝粒；3）大于11Mb的等位基因不平衡区域数量 ::

    Birkbak, N. J., Z. C. Wang, J. Y. Kim, A. C. Eklund, Q. Li, R. Tian, C. Bowman-Colin, et al. 2012. “Telomeric allelic imbalance indicates defective DNA repair and sensitivity to DNA-damaging agents.” Cancer Discov 2 (4): 366–75.

HRD score = sum of the TAI, LST, and LOH scores

# 二代测序数据分析

[scarHRD R软件包:https://github.com/sztup/scarHRD](https://github.com/sztup/scarHRD)

# 基于低深度全基因组测序分析

[shallowHRD R软件包:https://github.com/aeeckhou/shallowHRD](https://github.com/aeeckhou/shallowHRD)