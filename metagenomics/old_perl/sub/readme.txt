不同样本个数以及分组情况以及相关需求设定，可能只会分析出其中部分结构。以下是其一般目录结构：
├── assembly    									--组装结果目录，包含组装contig，组装结果评估以及map率               
├── binning     									--基因contig的binning分析结果目录，其结果在bins中
│   └── bins   
├── card											--抗性基因数据库CARD注释结果目录，包括比对结果、统计结果以及相关作图
├── CAZyme											--碳水化合物数据库CAZyme注释结果目录，包括比对结果以及相关作图
├── data_assess										--分析数据统计，包括reads，base以及Q20、Q30等指标
├── DGE												--基于DESEQ2进行基因统计差异分析目录，包含两两组之间统计结果表单
├── function_bar									--包含基于card、CAZyme、COG、KOG、eggNOG、KEGG等数据库大类注释的丰度柱状图
│   ├── card_abundance_bar
│   ├── cazyme_abundance_bar
│   ├── cog_abundance_bar
│   ├── eggnog_abundance_bar
│   ├── kegg_abundance_bar
│   └── kog_abundance_bar
├── gene											--基于基因table分析目录
│   ├── Anosim										--基于基因table的Anosim分析
│   ├── cluster										--基于基因table的样本聚类分析
│   ├── database_tables								--基于各数据库注释的基因table统计，且里边包含了kruskal统计检验分析（包括所有组及其两两间）、各数据库基因表单的丰度排行前50的heatmap、两两组间Anosim分析等
│   │   ├── card									
│   │     						
│   │   ├── CAZyme
│   │   						
│   │   ├── COG
│   │   ├── eggNOG
│   │   ├── KO
│   │   └── KOG
│   ├── flower_venn									--基于基因table的花瓣图/维恩图分析
│   ├── lefse										--基于部分数据库注释的lese分析
│   │   ├── lefse_card								--基于card数据库注释lefse分析
│   │   └── lefse_cazyme							--基于CAZyme数据库注释lefse分析
│   ├── PCA											--基于基因table的PCA分析
│   └── PCOA										--基于基因table的PCOA分析(基于bray-curtis计算)
├── pic												--网页报告配置文件pic文件夹
├── regular_anno									--常规8个数据库注释文件目录，包括COG、KOG、eggNOG、GO、KEGG、nr、Pfam、Swissport
│   ├── each_sample_anno							--单个样本的各数据库注释，包括CAZyme、COG、KOG、eggNOG、GO、KEGG、nr、Pfam、Swissport
│   │   ├── cazyme
│   │   ├── Cog
│   │   ├── Eggnog
│   │   ├── go
│   │   │   ├── A1-3
│   │   │   ├── A2-3
│   │   │   ├── B1-3
│   │   │   └── B2-3
│   │   ├── Kegg
│   │   │   ├── A1-3
│   │   │   │   └── Kegg_map
│   │   │   ├── A2-3
│   │   │   │   └── Kegg_map
│   │   │   ├── B1-3
│   │   │   │   └── Kegg_map
│   │   │   └── B2-3
│   │   │       └── Kegg_map
│   │   ├── Kog
│   │   ├── nr
│   │   ├── Pfam
│   │   └── Swissport
│   ├── Kegg_map
│   └── KEGG_wilcoxon_test							--基于KEGG数据库注释分析以基因、酶、ko为基础的基因表单计算及wilcoxon方法进行两两统计
│       ├── EC
│       ├── gene
│       └── ko
├── src												--网页报告配置文件src文件夹
│   ├── css
│   ├── images
│   └── js
│       └── fancyBox
└── taxonomy										--基于物种reads比对物种组成的相关分析目录
    ├── diamond										--基于diamond软件比对nr数据库物种组成分析目录
    │   ├── Anosim									--基于物种组成的Anosim分析
    │   ├── barplot									--基于物种组成的barplot分析
    │   ├── cluster									--基于物种组成的样本聚类分析
    │   ├── heatmap									--基于物种组成的heatmap分析（各水平丰度排行前20）
    │   ├── PCA										--基于物种组成的PCA分析
    │   └── PCOA									--基于物种组成的PCOA分析(基于bray-curtis计算)
    └── metaphlan									--基于metaphlan的物种组成分析
