#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use FindBin qw($Bin);
use Getopt::Long;
use XML::Writer;
use Config::IniFiles;
use IO::File;
my ($outdir,$config);

GetOptions(
     "i:s"=>\$config,
     "o:s"=>\$outdir, 
           );
sub usage{
     print qq{
 This script will produce the xml file.
 usage:
 perl $0 -i meta.config -o /path/to/directory
     };
     exit;
}
if(!$outdir||!$config)
{
     &usage();
}
my $num=1;
my $NUM=0;
my @big=("一","二","三","四","五","六","七","八","九","十");
my @small=('1','2','3','4','5','6','7','8','9','10');

my %ini;
tie %ini, 'Config::IniFiles', (-file =>$config);
my $output = IO::File->new(">$outdir/output.xml");
my $writer = XML::Writer->new(OUTPUT => $output,NAMESPACES => 1);
$writer->xmlDecl("UTF-8");

#first report title
print $output "\n";$writer->startTag("report");
print $output "\n";$writer->emptyTag("report_name", "value"=> "$ini{report}{title}");
#abstract
print $output "\n";$writer->emptyTag("report_abstract", "value"=>"");
#项目概况
print $output "\n";$writer->emptyTag('h1', 'name'=>"项目概况",'type'=>"一级标题显示样式",'desc'=>"一级标题描述");
print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"宏基因组学（metagenomics）是一种以环境样品中的微生物群体所有基因组作为研究对象，利用基因组学的研究策略研究环境样品中所包含的全部微生物的遗传组成及其群落功能的新的研究微生物多样性的方法。宏基因组不依赖于微生物的分离培养，克服了传统的纯培养方法的技术限制，为研究和开发利用占微生物种类99%以上的未可培养的微生物提供了一种新的途径和良好的策略； 可以得到环境中丰度较低的，甚至是痕量微生物的信息，为研究低丰度微生物提供了途径；它引入了宏观生态的研究理念，对环境中微生物菌群的多样性、功能活性等宏观特征进行研究，可以更准确地反应出微生物生存的真实状态。");
#########################
my ($total_G,$per_G,$gene_num,$contig_num);
open(CL,"$outdir/data_assess/statistics_fastq.xls");
while(<CL>)
{
     my @array=split;
     if($array[2]=~/[0-9]/)
     {
          $total_G+=$array[2];
     }
}

$total_G=$total_G/1000000000;
$per_G=$total_G/$ini{par}{sample_num};
$contig_num =`grep -c \\> $outdir/assembly/contig.fasta`;
chomp($contig_num);
$gene_num =`grep -c \\> $outdir/gene/non-redundant-nucl.fasta`;
chomp($gene_num);
my ($nr,$swissprot,$pfam,$kegg,$cog,$GO);
open(AN,"$outdir/regular_anno/Function_Annotation.stat.xls");
while(<AN>)
{
     my @array=split;
     if($array[0]=~"nr")
     {
          $nr=$array[1]/$gene_num*100;
     }
     if($array[0]=~"KEGG")
     {
          $kegg=$array[1]/$gene_num*100;
     }
     if($array[0]=~"COG")
     {
          $cog=$array[1]/$gene_num*100;
     }
     if($array[0]=~"Pfam")
     {
          $pfam=$array[1]/$gene_num*100;
     }
     
     if($array[0]=~"Swissprot")
     {
          $swissprot=$array[1]/$gene_num*100;
     }
     if($array[0]=~"GO")
     {
          $GO=$array[1]/$gene_num*100;
     }  
}


#实验建库测序
print $output "\n";$writer->emptyTag('h1', 'name'=>"实验流程",'type'=>"一级标题显示样式",'desc'=>"一级标题描述");
print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"从环境（如土壤、海洋、淡水、肠道等）中采集实验样本，将原始采样样本或已提取的 DNA 样本低温运输（ 0℃ 以下）送往我公司。我公司将对接收到的样品进行样品检测。检测合格的 DNA 样品，进行文库构建以及文库检测，检测合格的文库将采用 Illumina HiSeq 高通量测序平台进行测序，测序得到的下机数据(Raw Data)将用于后期信息分析。为了从源头上保证测序数据的准确性、可靠性，我公司对样品检测、建库、测序每一个生产步骤都严格把控，从根本上确保高质量数据的产出，具体的实验流程图如下：");
print $output "\n";$writer->emptyTag('pic',name=>" ",type=>'img-width-max',desc=>'',path=>"pic/shiyan.png");
	#样品检测
	print $output "\n";$writer->emptyTag('h2', 'name'=>"$num.样品检测",'type'=>"二级标题显示样式",'desc'=>"二级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"奥维森对 DNA 样品的检测主要包括 2 种方法：");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"(1) 琼脂糖凝胶电泳（AGE）分析 DNA 的纯度和完整性；");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"(2) Qubit 对 DNA 浓度进行精确定量；");
	#文库构建及库检
	$num++;
	print $output "\n";$writer->emptyTag('h2', 'name'=>"$num.文库构建及库检",'type'=>"二级标题显示样式",'desc'=>"二级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"检测合格的 DNA 样品用 Covaris 超声波破碎仪随机打断成长度约为 350bp 的片段，经末端修复、加 A尾、加测序接头、纯化、PCR 扩增等步骤完成整个文库制备。");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"文库构建完成后，先使用 Qubit2.0 进行初步定量，稀释文库至 2ng/ul，随后使用 Agilent 2100 对文库的 insert size 进行检测，insert size 符合预期后，使用 Q-PCR 方法对文库的有效浓度进行准确定量（文库有效浓度 ＞3nM），以保证文库质量。");
	#上机测序
	$num++;
	print $output "\n";$writer->emptyTag('h2', 'name'=>"$num.上机测序",'type'=>"二级标题显示样式",'desc'=>"二级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"库检合格后，把不同文库按照有效浓度及目标下机数据量的需求 pooling 后进行 Illumina HiSeq 测序。");

$num=1;	
#@big begins.and NUM=0 start.
#生物信息学分析
print $output "\n";$writer->emptyTag('h1', 'name'=>"信息分析流程",'type'=>"一级标题显示样式",'desc'=>"一级标题描述");
print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"宏基因组的生物信息分析，首先对测序数据进行质控，如果存在宿主基因组在质控过后需要去除宿主基因组。对质控过的数据进行组装，基因预测以及功能注释。通过测序数据与不同物种分类数据库的比对分析，得到样本间的物种分类信息，并找寻出差异丰度物种。此外还可以通过比较样本间差异丰度基因寻找可应用于功能比较的biomarker。宏基因组的生物信息分析流程见下图：");  
print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"宏基因组的生物信息分析流程见下图：");  
print $output "\n";$writer->emptyTag('pic',name=>" ",type=>'img-width-max',desc=>'',path=>"pic/metagenomics.png");
    #一.测序数据预处理
    print $output "\n";$writer->emptyTag('h2', 'name'=>"$big[$NUM]、测序数据预处理",'type'=>"二级标题显示样式",'desc'=>"二级标题描述");
    print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"测序得到的原始测序序列即raw reads,往往包含有带接头的、低质量的reads。为了保证信息分析质量,须对raw reads过滤,得到clean reads,后续分析都基于 clean reads。");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"质控部分的标准及原则如下：");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"(1) 过滤带有测序接头(adapter)的Reads；");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"(2) 过滤N(不确定碱基)含量比例大于1%的Reads；");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"(3) 过滤低质量碱基（Q≤20）含量大于50％的Reads。");
    print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"如果样品是测的一些宿主内的宏基因组那么就会可能存在宿主污染（如人体肠道，口腔等）,需要用bowtie2[1]软件以序列数据与宿主的参考基因组进行比对去除宿主 reads。最终数据过滤统计结果如下表所示：");
    print $output "\n";$writer->emptyTag('table','name'=>"",'type'=>"type1|full",'desc'=>"注：Samples：样品信息单样品名称；Read Number：Clean Data中pair-end Reads总数；Base Number：Clean Data总碱基数；GC Content：Clean Data GC含量,即Clean Data中G和C两种碱基占总碱基的百分比；%≥Q30：Clean Data质量值大于或等于30的碱基所占的百分比。",'path'=>"data_assess/statistics_fastq.xls");
    
	#二、宏基因组组装及基因预测
	$num=1;
	$NUM++;
    print $output "\n";$writer->emptyTag('h2', 'name'=>"$big[$NUM]、Metagenomics组装及其基因预测",'type'=>"二级标题显示样式",'desc'=>"二级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"通常地,在分析宏基因组的时候首先要对数据进行组装，用以后续分析。");
		#宏基因组组装
	print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.宏基因组组装",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"采用宏基因组组装软件MEGAHIT(v1.0.6)[2]对测序样本进行组装,过滤掉组装结果中 500bp 以下的片段,宏基因组数据组装统计结果如下表所示：");
    print $output "\n";$writer->emptyTag('table','name'=>"",'type'=>"type1|full",'desc'=>"",'path'=>"assembly/report.tsv");
    print $output "\n";$writer->emptyTag('file','name'=>"组装得到contig序列：assembly/contig.fasta",'type'=>"文件显示样式",'desc'=>"",'path'=>"assembly/contig.fasta",'action'=>"文件类型");
    print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"将测序数据比对到组装的contig序列片段上以评估组装过程中reads利用率，组装效率评估如下表：");
    print $output "\n";$writer->emptyTag('table','name'=>"",'type'=>"type1|full",'desc'=>"",'path'=>"assembly/mapped_ratio.xls");
		#基因预测及其非冗余基因集构建
	$num++;
	print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基因预测及非冗余基因集构建",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"得到组装的contig结果，采用 prodigal[3]软件对组装得到contig序列进行 ORF (Open Reading Frame) 预测,使用CD-HIT[4]软件对预测的基因序列以0.95相似度进行去除冗余得到非冗余基因集并采用Bowtie[5]软件将测序数据与构建的非冗余基因集进行比对,统计单个基因在不同样本的丰度信息并将其进行标准化计算得到基因丰度表。");
	print $output "\n";$writer->emptyTag('file','name'=>"非冗余基因集 (nucl)：gene/non-redundant-nucl.fasta",'type'=>"文件显示样式",'desc'=>"",'path'=>"gene/non-redundant-nucl.fasta",'action'=>"文件类型");
    print $output "\n";$writer->emptyTag('file','name'=>"非冗余基因集 (prot)：gene/non-redundant-prot.fasta",'type'=>"文件显示样式",'desc'=>"",'path'=>"gene/non-redundant-prot.fasta",'action'=>"文件类型");
	print $output "\n";$writer->emptyTag('file','name'=>"基于reads count的基因丰度表：gene/raw_count.txt",'type'=>"文件显示样式",'desc'=>"",'path'=>"gene/raw_count.txt",'action'=>"文件类型");
    print $output "\n";$writer->emptyTag('file','name'=>"标准化基因丰度表：gene/normalize_count.txt",'type'=>"文件显示样式",'desc'=>"",'path'=>"gene/normalize_count.txt",'action'=>"文件类型");
	
	#三、基于基因的丰度分析
	if($ini{par}{sample_num}>1){
		$num=1;
		$NUM++;
		print $output "\n";$writer->emptyTag('h2', 'name'=>"$big[$NUM]、基于基因的丰度分析",'type'=>"二级标题显示样式",'desc'=>"二级标题描述");
		print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"得到基因丰度表后，如果是多个样本则基于它进行多样本比较分析");
		#基因数目差异分析
		if(keys %{$ini{flower}}>0 or keys %{$ini{venn}}>0){
			print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基因数目差异分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
			print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"多个样本分析时，对于给定的以样本/组为单位的Venn图或花瓣图进行绘制,绘图结果如下所示");
			if(keys $ini{flower}>0 || keys $ini{venn}>0){
				my @vf=glob "gene/flower_venn/*.png";
				print $output "\n";$writer->startTag('pic_list','name'=>"",'type'=>'图片列表显示样式','desc'=>"");
				my $f=1;
				my $v=1;
				for(my $i=0;$i<=$#vf;$i++){
				if($vf[$i]=~/venn/i){
					print $output "\n";$writer->emptyTag('pic','name'=>"venn$v",'desc'=>"",'path'=>"$vf[$i]");
					$v++;
				}
				else{
					print $output "\n";$writer->emptyTag('pic','name'=>"flower$f",'desc'=>"",'path'=>"$vf[$i]");
					$f++
					}
				}
				print $output "\n";$writer->endTag("pic_list");
			}
			
		}
		if($ini{par}{sample_num}>2){
		#基于基因丰度的PCA分析
			$num++;
			print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于基因丰度的PCA分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
			print $output "\n";$writer->emptyTag('pic','name'=>"基于基因丰度的PCA",'type'=>'img-width-max','desc'=>"",'path'=>"gene/PCA/gene1.png");
			print $output "\n";$writer->emptyTag('file','name'=>"基于基因丰度PCA分析结果目录/",'type'=>"文件显示样式",'desc'=>"",'path'=>"gene/PCA/",'action'=>"文件类型");
		#基于基因丰度的PCOA分析	
			$num++;
			print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于基因丰度的PCOA分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
			print $output "\n";$writer->emptyTag('pic','name'=>"基于基因丰度的PCOA",'type'=>'img-width-max','desc'=>"",'path'=>"gene/PCOA/pcoa_gene.png");
			print $output "\n";$writer->emptyTag('file','name'=>"基于基因丰度的PCOA分析结果目录/",'type'=>"文件显示样式",'desc'=>"",'path'=>"gene/PCOA/",'action'=>"文件类型");
		#基于基因丰度的cluster聚类分析
			$num++;
			print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于基因丰度的样本聚类分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
			print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"基因丰度基于bray-curtis的cluster聚类分析，分析结果如下图所示：");
			print $output "\n";$writer->startTag('pic_list','name'=>"",'type'=>'图片列表显示样式','desc'=>"");
			print $output "\n";$writer->emptyTag('pic','name'=>"cluster1",'desc'=>"",'path'=>"gene/cluster/cluster1.png");
			print $output "\n";$writer->emptyTag('pic','name'=>"cluster2",'desc'=>"",'path'=>"gene/cluster/cluster2.png");
			print $output "\n";$writer->endTag("pic_list");
			print $output "\n";$writer->emptyTag('file','name'=>"基于基因的cluster分析结果目录/",'type'=>"文件显示样式",'desc'=>"",'path'=>"gene/cluster/",'action'=>"文件类型");
		}
		if($ini{par}{anosim}=~/t/i){
			#基于基因丰度的Anosim分析
			$num++;
			print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于基因丰度的Anosim分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
			print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"基于基因丰度的Anosim分析两两组比较结果及其所有组比较结果如下表所示");
			print $output "\n";$writer->emptyTag('table','name'=>"",'type'=>"type1|full",'desc'=>"",'path'=>"gene/Anosim/stat_anosim.txt");
			print $output "\n";$writer->emptyTag('file','name'=>"Anosim分析结果目录/",'type'=>"文件显示样式",'desc'=>"",'path'=>"gene/Anosim/",'action'=>"文件类型");
		}
	}
	#四、物种注释
	$num=1;
	$NUM++;
	print $output "\n";$writer->emptyTag('h2', 'name'=>"$big[$NUM]、物种注释",'type'=>"二级标题显示样式",'desc'=>"二级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"除了对基因table的分析，同样的也可以对样本的物种组成进行分析，这里用两个常用的方法及其数据库对物种组成做了比对分析。分别是基于reads使用diamond[6]比对nr数据库结合megan6[7]解析进行物种组成分析以及基于reads的MetaPhlAN[8]比对分析，以下除了单独MetaPhlAN分析模块之外都是基于nr注释的结果");
	#物种注释krona可视化分析
	print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.物种注释krona可视化分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"利用krona-tools进行交互式可视化显示结果如下，点击可以交互式查看：");
	print $output "\n";$writer->emptyTag('file','name'=>"krona.html",'type'=>"文件显示样式",'desc'=>"",'path'=>"taxonomy/diamond/krona.html",'action'=>"文件类型");
    print $output "\n";$writer->emptyTag('file','name'=>"基于nr数据库比对的分析结果目录：",'type'=>"文件显示样式",'desc'=>"",'path'=>"taxonomy/diamond/",'action'=>"文件类型");
	#物种注释相对丰度柱状图/饼图分析
	$num++;
	print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.物种注释相对丰度柱状图/饼图分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"详细物种组成如以下柱状图或饼图所示：");	 
	print $output "\n";$writer->startTag('pic_list','name'=>"",'type'=>'图片列表显示样式','desc'=>""); 
	my @barplots=glob "taxonomy/diamond/barplot/bar*.png";
	for(my $i=0;$i<=$#barplots;$i++){
		if($barplots[$i]=~/phylum/){
			print $output "\n";$writer->emptyTag('pic','name'=>"门水平物种组成",'desc'=>"",'path'=>"$barplots[$i]");
		}
		elsif($barplots[$i]=~/class/){
			print $output "\n";$writer->emptyTag('pic','name'=>"纲水平物种组成",'desc'=>"",'path'=>"$barplots[$i]");            
		}
		elsif($barplots[$i]=~/order/){
            print $output "\n";$writer->emptyTag('pic','name'=>"目水平物种组成",'desc'=>"",'path'=>"$barplots[$i]");
		}
		elsif($barplots[$i]=~/family/){
            print $output "\n";$writer->emptyTag('pic','name'=>"科水平物种组成",'desc'=>"",'path'=>"$barplots[$i]");
        }
		elsif($barplots[$i]=~/genus/){
            print $output "\n";$writer->emptyTag('pic','name'=>"属水平物种组成",'desc'=>"",'path'=>"$barplots[$i]");
        }
		elsif($barplots[$i]=~/species/){
            print $output "\n";$writer->emptyTag('pic','name'=>"种水平物种组成",'desc'=>"",'path'=>"$barplots[$i]");
        }
		else{
            next;    
        }
	}
	my @pies=glob "taxonomy/diamond/barplot/pie*.png";
	for(my $i=0;$i<=$#pies;$i++){
			if($pies[$i]=~/phylum/){
                print $output "\n";$writer->emptyTag('pic','name'=>"门水平饼图",'desc'=>"",'path'=>"$pies[$i]");
			}
			elsif($pies[$i]=~/class/){
                print $output "\n";$writer->emptyTag('pic','name'=>"刚水平饼图",'desc'=>"",'path'=>"$pies[$i]");
			}
			elsif($pies[$i]=~/order/){
                print $output "\n";$writer->emptyTag('pic','name'=>"目水平饼图",'desc'=>"",'path'=>"$pies[$i]");
			}
			elsif($pies[$i]=~/family/){
                print $output "\n";$writer->emptyTag('pic','name'=>"科水平饼图",'desc'=>"",'path'=>"$pies[$i]");
			}
			elsif($pies[$i]=~/genus/){
                print $output "\n";$writer->emptyTag('pic','name'=>"属水平饼图",'desc'=>"",'path'=>"$pies[$i]");
			}
			elsif($pies[$i]=~/species/){
                print $output "\n";$writer->emptyTag('pic','name'=>"种水平饼图",'desc'=>"",'path'=>"$pies[$i]");
			}
			else{
				next;
			}
	}
	print $output "\n";$writer->endTag("pic_list");
	#物种注释丰度聚类热图
	$num++;
	print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.物种注释丰度聚类热图",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"对于样本数目大于等于2的时候，进行各个水平排名丰度前20的物种进行热力图分析");
	my @spe_heatmaps=glob"taxonomy/diamond/heatmap/*.png";
	print $output "\n";$writer->startTag('pic_list','name'=>"",'type'=>'图片列表显示样式','desc'=>"");
	for(my $i=0;$i<=$#spe_heatmaps;$i++){
		my $level=(split /\./,(split /\_/,(split /\//,$spe_heatmaps[$i])[-1])[1])[0];
		print $output "\n";$writer->emptyTag('pic','name'=>"$level水平heatmap",'desc'=>"",'path'=>"$spe_heatmaps[$i]");
	}
	print $output "\n";$writer->endTag("pic_list");
	print $output "\n";$writer->emptyTag('file','name'=>"基于物种组成heatmap分析结果目录：",'type'=>"文件显示样式",'desc'=>"",'path'=>"taxonomy/diamond/heatmap",'action'=>"文件类型");
	#基于物种丰度的PCA分析
	$num++;
	if($ini{par}{sample_num}>2){
		print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于物种丰度的PCA分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
		print $output "\n";$writer->emptyTag('pic','name'=>"基于物种组成的PCA",'type'=>'img-width-max','desc'=>"",'path'=>"taxonomy/diamond/PCA/species.png");
		print $output "\n";$writer->emptyTag('file','name'=>"基于物种组成的PCA分析结果目录/",'type'=>"文件显示样式",'desc'=>"",'path'=>"taxonomy/diamond/PCA/",'action'=>"文件类型");
	
	#基于物种丰度的PCOA分析
		$num++;
		print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于物种丰度的PCOA分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
		print $output "\n";$writer->emptyTag('pic','name'=>"基于物种组成的PCOA",'type'=>'img-width-max','desc'=>"",'path'=>"taxonomy/diamond/PCOA/pcoa_species.png");
		print $output "\n";$writer->emptyTag('file','name'=>"基于物种组成的PCOA分析结果目录/",'type'=>"文件显示样式",'desc'=>"",'path'=>"taxonomy/diamond/PCOA/",'action'=>"文件类型");
	
	#基于物种丰度的样本聚类分析
		$num++;
		print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于物种丰度的样本聚类分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
		print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"物种组成进行基于bray-curtis的cluster聚类分析，分析结果如下图所示：");
		print $output "\n";$writer->startTag('pic_list','name'=>"",'type'=>'图片列表显示样式','desc'=>"");
		print $output "\n";$writer->emptyTag('pic','name'=>"cluster1",'desc'=>"",'path'=>"taxonomy/diamond/cluster/cluster1.png");
		print $output "\n";$writer->emptyTag('pic','name'=>"cluster2",'desc'=>"",'path'=>"taxonomy/diamond/cluster/cluster2.png");
		print $output "\n";$writer->endTag("pic_list");
		print $output "\n";$writer->emptyTag('file','name'=>"cluster分析结果目录/",'type'=>"文件显示样式",'desc'=>"",'path'=>"taxonomy/diamond/cluster/",'action'=>"文件类型");
	}
	#基于物种丰度的Anosim分析
	if($ini{par}{anosim}=~/t/i){
		$num++;
		print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于物种丰度的Anosim分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
		print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"基于物种组成的Anosim分析两两组比较结果及其所有组比较结果如下表所示");
		print $output "\n";$writer->emptyTag('table','name'=>"",'type'=>"type1|full",'desc'=>"",'path'=>"taxonomy/diamond/Anosim/stat_anosim.txt");
		print $output "\n";$writer->emptyTag('file','name'=>"Anosim分析结果目录/",'type'=>"文件显示样式",'desc'=>"",'path'=>"taxonomy/diamond/Anosim/",'action'=>"文件类型");
	}
	#基于物种丰度Wilcoxon组间差异物种分析
	if($ini{par}{wilcoxon}=~/t/i){
		$num++;
		print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于物种丰度Wilcoxon组间差异物种分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
		print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"当生物学重复大于的时候，用wilcoxon的统计方法对门纲目科属等水平菌落进行两两组之间的统计检验，并将得到的差异物种进行热力图分析和err bar，结果在以下目录，其中.test.txt为统计检验结果，diff前缀txt文件为差异物种，errbar前缀为带有误差线的柱状图，diff前缀的pdf图片为差异物种热图：");
		print $output "\n";$writer->emptyTag('file','name'=>"基于物种丰度Wilcoxon组间差异物种分析结果目录/",'type'=>"文件显示样式",'desc'=>"",'path'=>"taxonomy/diamond/wilcoxon/",'action'=>"文件类型");
	}
	#基于物种lefse分析
	if($ini{par}{lefse}=~/t/i){
		$num++;
		print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于物种lefse分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
		print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"当至少有2个组别进行分析，且每组都有2个以上生物学重复时候，进行lefse分析。以下为其分析结果目录，其中lefse.diamond.res为计算结果，lefse.diamond.png为LDA图，zip文件为所有具有差异物种的柱状图");
		print $output "\n";$writer->emptyTag('file','name'=>"基于物种组成的lefse分析结果目录",'type'=>"文件显示样式",'desc'=>"",'path'=>"taxonomy/diamond/lefse/",'action'=>"文件类型");
	}
	#基于MetaPhlAN的物种注释
	$num++;
	print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于MetaPhlAN的物种注释",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"MetaPhlAn(https://bitbucket.org/biobakery/metaphlan2)数据库包含约有1M的功能基因,可识别约17000物种（13500细菌与古细菌,3500病毒与110真核生物）。将质控过的测序数据比对到MetaPhlAn数据库，并进行结果展示");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"将clean reads比对到MetaPhlAN数据库的比对情况如下图表所示：");
	#print $output "\n";$writer->emptyTag('table','name'=>"",'type'=>"type1|full",'desc'=>"",'path'=>"taxonomy/metaphlan/mapped_ratio.xls");
    print $output "\n";$writer->startTag('pic_list','name'=>"",'type'=>'图片列表显示样式','desc'=>"");
	my @mp=glob "taxonomy/metaphlan/*.png";
	for(my $i=0;$i<=$#mp;$i++){
		my @mp_name=split /\./,(split /\//,$mp[$i])[-1];
		pop @mp_name;
		my $mp_name=join(".",@mp_name);
		if($mp_name eq 'merged'){
			print $output "\n";$writer->emptyTag('pic','name'=>"总体图",'desc'=>"",'path'=>"$mp[$i]");
		}
		else{
			print $output "\n";$writer->emptyTag('pic','name'=>"样本$mp_name",'desc'=>"",'path'=>"$mp[$i]");
		}
	}
	print $output "\n";$writer->endTag("pic_list");
	
	#五、功能注释
	$NUM++;
	$num=1;
	print $output "\n";$writer->emptyTag('h2', 'name'=>"$big[$NUM]、功能注释",'type'=>"二级标题显示样式",'desc'=>"二级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"对于预测出来的基因序列，要研究其功能就要对其进行注释，这里用一些常用的功能数据库对其进行注释，包括COG/KOG、KEGG、nr、eggNOG、Pfam、GO、Swissport、CAZyme、CARD等");
	#基因注释数目分析
	print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基因注释数目分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"将预测得到非冗余基因集与常规的功能注释数据库nr、Swiss-Prot、Kegg、Cog/Kog、eggNOG、GO、Pfam[9-11]进行比对,比对统计基因注释个数结果如下:");
	print $output "\n";$writer->emptyTag('table','name'=>"",'type'=>"type1|full",'desc'=>"",'path'=>"regular_anno/Function_Annotation.stat.xls");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"基于nr数据库的获得的基因物种分类结果如下图：");
    print $output "\n";$writer->emptyTag('pic','name'=>"",'type'=>'img-width-max','desc'=>"",'path'=>"regular_anno/non-redundant-nucl.fasta.nr.lib.png");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"基于COG数据库的蛋白质家族注释分类结果如下：");
    print $output "\n";$writer->emptyTag('pic','name'=>"",'type'=>'img-width-max','desc'=>"",'path'=>"regular_anno/non-redundant-nucl.fasta.Cog.cluster.png");
    print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"基于KOG数据库的蛋白质家族注释分类结果如下：");
    print $output "\n";$writer->emptyTag('pic','name'=>"",'type'=>'img-width-max','desc'=>"",'path'=>"regular_anno/non-redundant-nucl.fasta.Kog.cluster.png");
    print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"基于GO数据库的基因功能分类结果如下：");
    print $output "\n";$writer->emptyTag('pic','name'=>"",'type'=>'img-width-max','desc'=>"",'path'=>"regular_anno/non-redundant-nucl.fasta.GO.png");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"KEGG 数据库为一个综合性数据库，其中最核心的为 KEGG PATHWAY 和 KEGG ORTHOLOGY 数据库。在 KEGG PATHWAY 数据库中，将生物代谢通路划分为 6 类，分别为：细胞过程（Cellular Processes）、环境信息处理（Environmental Information Processing）、遗传信息处理（Genetic Information Processing）、人类疾病（Human Diseases）、新陈代谢（Metabolism）、生物体系统（Organismal Systems），KEGG 数据库在研究基因功能方面发挥着重要的作用，是 Metagenomics 分析中，必不可少的一部分。基于KEGG数据库的基因功能分类结果如下：");
    print $output "\n";$writer->emptyTag('pic','name'=>"",'type'=>'img-width-max','desc'=>"",'path'=>"regular_anno/KO_classification.png");
    print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"目前,抗生素抗性基因的研究主要利用ARDB[12]（Antibiotic Resistance Genes Database) 和CARD[13]（Comprehensive Antibiotic Resistance Database）数据库。由于ARDB很久没有更新，而CARD一直保持更新而且包括了ARDB的所有基因，所以这里用CARD数据库进行注释。通过该数据库的注释,可以找到耐药性相关基因的类型（ Resistance Type, ARG）以及这些基因所耐受的抗生素种类（ Antibiotic）等信息。");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"借助blast比对软件,将非冗余基因序列与抗生素基因数据库进行比对,对比对结果进行统计分析.结合注释到非冗余基因的丰度信息，绘制下图：");
	print $output "\n";$writer->emptyTag('pic','name'=>"",'type'=>'img-width-max','desc'=>"注：这里仅列举前列丰度较多的ARO，详见结果目录附件",'path'=>"card/non-redundant-nucl.fasta.png");
	print $output "\n";$writer->emptyTag('file','name'=>"比对结果详情查看(包括taxonomy，基因名，ARO等)",'type'=>"文件显示样式",'desc'=>"",'path'=>"card/non-redundant-nucl.fasta_final_result.xls",'action'=>"文件类型");
    print $output "\n";$writer->emptyTag('file','name'=>"card结果目录：card/",'type'=>"文件显示样式",'desc'=>"",'path'=>"card/",'action'=>"文件类型");
    print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"CAZyme[14] 数据库是研究碳水化合物酶的专业级数据库,主要涵盖 6 大功能类：糖苷水解酶（Glycoside Hydrolases ,GHs）,糖基转移酶（Glycosyl Transferases,GTs）,多糖裂合酶（Polysaccharide Lyases,PLs）,碳水化合物酯酶（Carbohydrate Esterases,CEs）,辅助氧化还原酶(Auxiliary Activities , AAs)和碳水化合物结合模块（Carbohydrate-Binding Modules, CBMs）。");
    print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"对于CAZyme数据库注释,主要是借助HMMER软件,将非冗余基因序列与数据库进行比对,通过寻找序列间行使功能相似的功能域,对未知序列进行注释。");
    print $output "\n";$writer->emptyTag('pic','name'=>"基于CAZyme的注释统计结果",'type'=>'img-width-max','desc'=>"",'path'=>"CAZyme/cazyme.png");
	print $output "\n";$writer->emptyTag('file','name'=>"CAZyme注释结果目录：CAZyme/",'type'=>"文件显示样式",'desc'=>"",'path'=>"CAZyme/",'action'=>"文件类型");
	print $output "\n";$writer->emptyTag('file','name'=>"功能注释结果目录：regular_anno/",'type'=>"文件显示样式",'desc'=>"",'path'=>"regular_anno/",'action'=>"文件类型");
	print $output "\n";$writer->emptyTag('file','name'=>"以每单个样本计算的常规功能注释结果目录：regular_anno/each_sample_anno/",'type'=>"文件显示样式",'desc'=>"",'path'=>"regular_anno/each_sample_anno/",'action'=>"文件类型");
	#基于各个数据库基因功能相对丰度分析
	$num++;
	print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于各个数据库基因功能相对丰度分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"对于样本数目大于1的，进行基因各数据库注释的柱状图丰度分析,等于1的进行饼图分析。结果如下图所示：");
	my @genebars=glob "function_bar/*/*png";
	print $output "\n";$writer->startTag('pic_list','name'=>"",'type'=>'图片列表显示样式','desc'=>"");
	for(my $i=0;$i<=$#genebars;$i++){
		my $type=(split /\./,(split /\//,$genebars[$i])[-1])[0];
		print $output "\n";$writer->emptyTag('pic','name'=>"$type基因柱状图",'desc'=>"",'path'=>"$genebars[$i]");
	}
	print $output "\n";$writer->endTag("pic_list");
	#功能丰度聚类热图分析
	if($ini{par}{sample_num}>1){
		$num++;
		print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.功能丰度聚类热图分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
		print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"对于各个数据库进行注释后，根据各数据库进行基因表单统计，样本数大于1则对其丰度前50进行聚类热图分析，以下为各热图");
		print $output "\n";$writer->startTag('pic_list','name'=>"",'type'=>'图片列表显示样式','desc'=>"");
		my @d_heatmaps=glob "gene/database_tables/*/*.heatmap.png";
		for(my $i=0;$i<=$#d_heatmaps;$i++){
			my $type=(split /\//,$d_heatmaps[$i])[-2];
			print $output "\n";$writer->emptyTag('pic','name'=>"$type丰度前50 heatmap",'desc'=>"",'path'=>"$d_heatmaps[$i]");
		}
		print $output "\n";$writer->endTag("pic_list");
	}
	#基于功能丰度的Anosim分析
	if($ini{par}{anosim}=~/t/i){
		$num++;
		print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于功能丰度的Anosim分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
		my @anosims=glob "gene/database_tables/*/anosim_*.txt";
		for(my $i=0;$i<=$#anosims;$i++){
			my $anosim_type=(split /\//,$anosims[$i])[-2];
			print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"基于$anosim_type的功能丰度Anosim分析如下表所示:");
			print $output "\n";$writer->emptyTag('table','name'=>"",'type'=>"type1|full",'desc'=>"",'path'=>"$anosims[$i]");
			print $output "\n";$writer->emptyTag('file','name'=>"结果链接",'type'=>"文件显示样式",'desc'=>"",'path'=>"$anosims[$i]",'action'=>"文件类型");
		}
	}
	if($ini{par}{anosim}=~/t/i){
	#Kruskal组间差异功能分析
		$num++;
		print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于功能丰度的Kruskal-Wallis统计分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
		print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"当有生物学重复的时候，对所有组以及两两组之间进行kruskal-wallis统计分析，找到其不同功能丰度的差异，以下为基于各功能数据库的结果目录，其中all kruskal标记的文件是所有组检验，_static.txt文件为两两组间检验结果");
		my @kruskals_dir=glob "gene/database_tables/*";
		for(my $i=0;$i<=$#kruskals_dir;$i++){
			my $kruskals_type=(split /\//,$kruskals_dir[$i])[-1];
			print $output "\n";$writer->emptyTag('file','name'=>"基于 $kruskals_type 统计检验结果目录",'type'=>"文件显示样式",'desc'=>"",'path'=>"$kruskals_dir[$i]",'action'=>"文件类型");
		}
	}
	if($ini{par}{DESeq2}=~/t/i){
	#基于基因DESeq2分析
			$num++;
			print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于基因DESeq2分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
			print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"借助统计软件R中edgeR[15]包和DESeq2[16]包,分析不同样本见间的差异丰度基因,差异分析结果如下目录：");
			print $output "\n";$writer->emptyTag('file','name'=>"基因差异分析结果目录：DGE/",'type'=>"文件显示样式",'desc'=>"",'path'=>"DGE/",'action'=>"文件类型");
	}
	#六、抗性基因分析
	$NUM++;
	$num=1;
	print $output "\n";$writer->emptyTag('h2', 'name'=>"$big[$NUM]、抗性基因分析",'type'=>"二级标题显示样式",'desc'=>"二级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"前文有提到抗性基因分析的部分内容，抗性基因用非冗余基因集比对CARD数据库来注释基因集中的抗性基因。这里基于比对注释结果分析每个ARO的丰度情况以及样本聚类和寻找基于lefse方法的biomaker，并找到基因序列的物种归属信息");
	#抗性基因注释相对丰度分析
	print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.抗性基因注释相对丰度分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	print $output "\n";$writer->emptyTag('pic','name'=>"",'type'=>'img-width-max','desc'=>"抗性基因相对丰度柱状图",'path'=>"gene/database_tables/card/bar.ALL.percent_card.txt.png");
	if($ini{par}{sample_num}>2){
	#基于抗性基因功能丰度样本聚类分析
		$num++;
		print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.基于抗性基因功能丰度样本聚类分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
		print $output "\n";$writer->startTag('pic_list','name'=>"",'type'=>'图片列表显示样式','desc'=>"");
		print $output "\n";$writer->emptyTag('pic','name'=>"cluster1",'desc'=>"",'path'=>"gene/cluster/card/cluster1.png");
		print $output "\n";$writer->emptyTag('pic','name'=>"cluster2",'desc'=>"",'path'=>"gene/cluster/card/cluster2.png");
		print $output "\n";$writer->endTag("pic_list");
		print $output "\n";$writer->emptyTag('file','name'=>"card样本聚类分析结果目录/",'type'=>"文件显示样式",'desc'=>"",'path'=>"gene/cluster/card",'action'=>"文件类型");
	}
	
	if($ini{par}{lefse}=~/t/i){
	#Lefse组间差异抗性基因功能分析
		$num++;
		print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.Lefse组间差异抗性基因功能分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
		print $output "\n";$writer->emptyTag('file','name'=>"Lefse组间差异抗性基因功能分析结果目录/",'type'=>"文件显示样式",'desc'=>"",'path'=>"gene/lefse/lefse_card",'action'=>"文件类型");
	}
	#抗性基因归属分析
	$num++;
	print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.抗性基因归属分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"通过数据库的检索比对，我们可以找到比对基因序列对应的ARO编号、物种信息以及抗性基因名称、类型及其描述信息，可以点击以下附件进行查看");
	print $output "\n";$writer->emptyTag('file','name'=>"抗性基因归属分析结果文件.xls",'type'=>"文件显示样式",'desc'=>"",'path'=>"card/non-redundant-nucl.fasta_final_result.xls",'action'=>"文件类型");
	
	#七、高级分析
	$NUM++;
	$num=1;
	print $output "\n";$writer->emptyTag('h2', 'name'=>"$big[$NUM]、高级分析",'type'=>"二级标题显示样式",'desc'=>"二级标题描述");
	##Contig binning分析
	print $output "\n";$writer->emptyTag('h3', 'name'=>"$small[$NUM].$num.Contig binning分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"binning的含义是分箱、聚类，指从微生物群体序列中将不同个体的序列（reads或contigs等）分离开来的过程。简单来说就是把宏基因组数据中来自同一菌株的序列聚到一起得到若干bins。基于binning结果还可以进一步进行组装或者一些关联分析。");
	print $output "\n";$writer->emptyTag('file','name'=>"基于contig使用MATBAT[17]软件进行binning分析结果目录：",'type'=>"文件显示样式",'desc'=>"",'path'=>"binning/Result/bins",'action'=>"文件类型");

print $output "\n"; $writer->startTag('ref_list','name'=>"参考文献",'type'=>"参考文献列表显示样式",'desc'=>"参考文献列表描述");
#bowtie2
print $output "\n";$writer->emptyTag('ref','id'=>"1",'name'=>"Langmead B, Wilks C, Antonescu V, Charles R. Scaling read aligners to hundreds of threads on general-purpose processors. Bioinformatics. 2018 Jul 18. doi: 10.1093/bioinformatics/bty648.",'link'=>"https://academic.oup.com/bioinformatics/advance-article/doi/10.1093/bioinformatics/bty648/5055585");
#megahit
print $output "\n";$writer->emptyTag('ref','id'=>"2",'name'=>"Li D, Liu C M, Luo R, et al. MEGAHIT: an ultra-fast single-node solution for large and complex metagenomics assembly via succinct de Bruijn graph[J]. Bioinformatics, 2015: btv033.",'link'=>"http://bioinformatics.oxfordjournals.org/content/early/2015/01/19/bioinformatics.btv033.shortl");
#prodigal
print $output "\n";$writer->emptyTag('ref','id'=>"3",'name'=>"Hyatt D, Locascio PF, Hauser LJ, Uberbacher EC. 2012. Gene and translation initiation site prediction in metagenomic sequences. Bioinformatics 28: 2223–2230.",'link'=>"http://prodigal.ornl.gov/");
#cd-hit
print $output "\n";$writer->emptyTag('ref','id'=>"4",'name'=>"Li W, Jaroszewski L, Godzik A. Clustering of highly homologous sequences to reduce the size of large protein databases[J]. Bioinformatics, 2001, 17(3): 282-283.",'link'=>"https://academic.oup.com/bioinformatics");
#bowtie
print $output "\n";$writer->emptyTag('ref','id'=>"5",'name'=>"Langmead B, Trapnell C, Pop M, Salzberg SL. Ultrafast and memory-efficient alignment of short DNA sequences to the human genome. Genome Biol 10:R25.",'link'=>"https://genomebiology.biomedcentral.com/articles/10.1186/gb-2009-10-3-r25");
#diamond
print $output "\n";$writer->emptyTag('ref','id'=>"6",'name'=>"Buchfink B, Xie C, Huson D H. Fast and sensitive protein alignment using DIAMOND[J]. Nature methods, 2015, 12(1): 59-60.",'link'=>"http://www.nature.com/nmeth/journal/v12/n1/full/nmeth.3176.html");
#MEGAN
print $output "\n";$writer->emptyTag('ref','id'=>"7",'name'=>"Huson D H, Beier S, Flade I, et al. MEGAN Community Edition-Interactive Exploration and Analysis of Large-Scale Microbiome Sequencing Data[J]. PLoS Comput Biol, 2016, 12(6): e1004957.",'link'=>"http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1004957");
#metaPhlAn2
print $output "\n";$writer->emptyTag('ref','id'=>"8",'name'=>"MetaPhlAn2 for enhanced metagenomic taxonomic profiling. Duy Tin Truong, Eric A Franzosa, Timothy L Tickle, Matthias Scholz, George Weingart, Edoardo Pasolli, Adrian Tett, Curtis Huttenhower & Nicola Segata. Nature Methods 12, 902–903 (2015)",'link'=>"http://www.nature.com/nmeth/journal/v12/n10/full/nmeth.3589.html");
#blast
print $output "\n";$writer->emptyTag('ref','id'=>"9",'name'=>"Altschul S F, Madden T L, Schäffer A A, et al. Gapped BLAST and PSI-BLAST: a new generation of protein database search programs[J]. Nucleic acids research, 1997, 25(17): 3389-3402.",'link'=>"https://nar.oxfordjournals.org/content/25/17/3389.full");
#KOBAS
print $output "\n";$writer->emptyTag('ref','id'=>"10",'name'=>"Xie C, Mao X, Huang J, et al. KOBAS 2.0: a web server for annotation and identification of enriched pathways and diseases[J]. Nucleic acids research, 2011, 39(suppl 2): W316-W322.",'link'=>"http://nar.oxfordjournals.org/content/39/suppl_2/W316.short");
#HMM
print $output "\n";$writer->emptyTag('ref','id'=>"11",'name'=>"Eddy S R. Profile hidden Markov models[J]. Bioinformatics, 1998, 14(9): 755-763.",'link'=>"http://bioinformatics.oxfordjournals.org/content/14/9/755.short");
#ARDB
print $output "\n";$writer->emptyTag('ref','id'=>"12",'name'=>"Liu B, Pop M. ARDB—antibiotic resistance genes database[J]. Nucleic acids research, 2009, 37(suppl 1): D443-D447.",'link'=>"http://nar.oxfordjournals.org/content/37/suppl_1/D443.abstract");
#CARD
print $output "\n";$writer->emptyTag('ref',id=>'13','name'=>"Arango-Argoty G, Singh G, Heath L S, et al. MetaStorm: A Public Resource for Customizable Metagenomics Annotation[J]. Plos One, 2016, 11(9):e0162442.",'link'=>"https://www.researchgate.net/publication/308174735_MetaStorm_A_Public_Resource_for_Customizable_Metagenomics_Annotation");
#CAZyme
print $output "\n";$writer->emptyTag('ref','id'=>"14",'name'=>"Yin Y, Mao X, Yang J, et al. dbCAN: a web resource for automated carbohydrate-active enzyme annotation[J]. Nucleic acids research, 2012, 40(W1): W445-W451.",'link'=>"http://nar.oxfordjournals.org/content/40/W1/W445.long");
#edgeR
print $output "\n";$writer->emptyTag('ref','id'=>"15",'name'=>"Robinson M D, McCarthy D J, Smyth G K. edgeR: a Bioconductor package for differential expression analysis of digital gene expression data[J]. Bioinformatics, 2010, 26(1): 139-140.",'link'=>"http://bioinformatics.oxfordjournals.org/content/26/1/139");
#DESeq2
print $output "\n";$writer->emptyTag('ref','id'=>"16",'name'=>"Jonsson V, Österlund T, Nerman O, et al. Statistical evaluation of methods for identification of differentially abundant genes in comparative metagenomics[J]. BMC genomics, 2016, 17(1): 1.",'link'=>"https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-016-2386-y");
#matbat
print $output "\n";$writer->emptyTag('ref','id'=>"17",'name'=>"Dongwan D. Kang, Jeff Froula , Rob Egan and Zhong Wang: MetaBAT, an efficient tool for accurately reconstructing single genomes from complex microbial communitie.",'link'=>"https://peerj.com/articles/1165/");


print $output "\n";$writer->endTag("ref_list");
print $output "\n";$writer->endTag("report");
print $output "\n";$writer->end();
print $output "\n";$output->close();	
=head
	
	#kegg及其其他如ipath等分析 下次更新加上
#其他分析  
	print $output "\n";$writer->emptyTag('h2', 'name'=>"其他分析",'type'=>"二级标题显示样式",'desc'=>"二级标题描述");
	print $output "\n";$writer->emptyTag('h3', 'name'=>"基于KEGG的其他分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
#ko	
	print $output "\n";$writer->emptyTag('h4', 'name'=>"基于KEGG的ko pathway分析",'type'=>"四级标题显示样式",'desc'=>"四级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"通过基因表单，计算每个ko的丰度，如有生物学重复则另外对其用wilcoxon计算两两组之间的差异，并用err-barplot以及heatmap对具有差异的ko进行绘图");
	print $output "\n";$writer->emptyTag('file','name'=>"基于KEGG数据库的pathway统计分析结果目录：",'type'=>"文件显示样式",'desc'=>"",'path'=>"regular_anno/KEGG_wilcoxon_test/ko",'action'=>"文件类型");
#EC	
	print $output "\n";$writer->emptyTag('h4', 'name'=>"基于KEGG的酶分析",'type'=>"四级标题显示样式",'desc'=>"四级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"通过基因表单，计算每个酶的丰度，如有生物学重复则另外对其用wilcoxon计算两两组之间的差异，并用err-barplot以及heatmap对具有差异的酶进行绘图");
	print $output "\n";$writer->emptyTag('file','name'=>"基于KEGG数据库的EC（酶）统计分析结果目录：",'type'=>"文件显示样式",'desc'=>"",'path'=>"regular_anno/KEGG_wilcoxon_test/EC",'action'=>"文件类型");
#gene
	print $output "\n";$writer->emptyTag('h4', 'name'=>"基于KEGG的基因分析",'type'=>"四级标题显示样式",'desc'=>"四级标题描述");
	print $output "\n";$writer->emptyTag('p','type'=>'正文段落显示样式','desc'=>"通过基因表单，计算每个基因的丰度，如有生物学重复则另外对其用wilcoxon计算两两组之间的差异，并用err-barplot以及heatmap对具有差异的基因进行绘图");
	print $output "\n";$writer->emptyTag('file','name'=>"基于KEGG数据库的gene统计分析结果目录：",'type'=>"文件显示样式",'desc'=>"",'path'=>"regular_anno/KEGG_wilcoxon_test/gene",'action'=>"文件类型");
	
#基于基因组装结果contig的binning分析
	print $output "\n";$writer->emptyTag('h3', 'name'=>"基于基因组装结果contig的binning分析",'type'=>"三级标题显示样式",'desc'=>"三级标题描述");
	
	
	
#参考文献

#metaPhlAn2
#print $output "\n";$writer->emptyTag('ref','id'=>"",'name'=>"MetaPhlAn2 for enhanced metagenomic taxonomic profiling. Duy Tin Truong, Eric A Franzosa, Timothy L Tickle, Matthias Scholz, George Weingart, Edoardo Pasolli, Adrian Tett, Curtis Huttenhower & Nicola Segata. Nature Methods 12, 902–903 (2015)",'link'=>"http://www.nature.com/nmeth/journal/v12/n10/full/nmeth.3589.html");
#kraken
#print $output "\n";$writer->emptyTag('ref','id'=>"2",'name'=>"1.	Wood DE, Salzberg SL: Kraken: ultrafast metagenomic sequence classification using exact alignments. Genome Biology 2014, 15:R46.",'link'=>"https://genomebiology.biomedcentral.com/articles/10.1186/gb-2014-15-3-r46");
#diamond
print $output "\n";$writer->emptyTag('ref','id'=>"1",'name'=>"Buchfink B, Xie C, Huson D H. Fast and sensitive protein alignment using DIAMOND[J]. Nature methods, 2015, 12(1): 59-60.",'link'=>"http://www.nature.com/nmeth/journal/v12/n1/full/nmeth.3176.html");
#MEGAN
print $output "\n";$writer->emptyTag('ref','id'=>"2",'name'=>"Huson D H, Beier S, Flade I, et al. MEGAN Community Edition-Interactive Exploration and Analysis of Large-Scale Microbiome Sequencing Data[J]. PLoS Comput Biol, 2016, 12(6): e1004957.",'link'=>"http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1004957");
#metaPhlAn2
print $output "\n";$writer->emptyTag('ref','id'=>"3",'name'=>"MetaPhlAn2 for enhanced metagenomic taxonomic profiling. Duy Tin Truong, Eric A Franzosa, Timothy L Tickle, Matthias Scholz, George Weingart, Edoardo Pasolli, Adrian Tett, Curtis Huttenhower & Nicola Segata. Nature Methods 12, 902–903 (2015)",'link'=>"http://www.nature.com/nmeth/journal/v12/n10/full/nmeth.3589.html");
#edgeR
print $output "\n";$writer->emptyTag('ref','id'=>"4",'name'=>"Robinson M D, McCarthy D J, Smyth G K. edgeR: a Bioconductor package for differential expression analysis of digital gene expression data[J]. Bioinformatics, 2010, 26(1): 139-140.",'link'=>"http://bioinformatics.oxfordjournals.org/content/26/1/139");
#DESeq2
print $output "\n";$writer->emptyTag('ref','id'=>"5",'name'=>"Jonsson V, Österlund T, Nerman O, et al. Statistical evaluation of methods for identification of differentially abundant genes in comparative metagenomics[J]. BMC genomics, 2016, 17(1): 1.",'link'=>"https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-016-2386-y");
#megahit
print $output "\n";$writer->emptyTag('ref','id'=>"6",'name'=>"Li D, Liu C M, Luo R, et al. MEGAHIT: an ultra-fast single-node solution for large and complex metagenomics assembly via succinct de Bruijn graph[J]. Bioinformatics, 2015: btv033.",'link'=>"http://bioinformatics.oxfordjournals.org/content/early/2015/01/19/bioinformatics.btv033.shortl");
#MetaGeneMark
#print $output "\n";$writer->emptyTag('ref','id'=>"6",'name'=>"Hyatt D, LoCascio P F, Hauser L J, et al. Gene and translation initiation site prediction in metagenomic sequences[J]. Bioinformatics, 2012, 28(17): 2223-2230.",'link'=>"http://bioinformatics.oxfordjournals.org/content/28/17/2223.long");
#prodigal
print $output "\n";$writer->emptyTag('ref','id'=>"7",'name'=>"Hyatt D, Locascio PF, Hauser LJ, Uberbacher EC. 2012. Gene and translation initiation site prediction in metagenomic sequences. Bioinformatics 28: 2223–2230.",'link'=>"http://prodigal.ornl.gov/");
#cd-hit
print $output "\n";$writer->emptyTag('ref','id'=>"7",'name'=>"Li W, Jaroszewski L, Godzik A. Clustering of highly homologous sequences to reduce the size of large protein databases[J]. Bioinformatics, 2001, 17(3): 282-283.",'link'=>"https://academic.oup.com/bioinformatics");
#blast
print $output "\n";$writer->emptyTag('ref','id'=>"8",'name'=>"Altschul S F, Madden T L, Schäffer A A, et al. Gapped BLAST and PSI-BLAST: a new generation of protein database search programs[J]. Nucleic acids research, 1997, 25(17): 3389-3402.",'link'=>"https://nar.oxfordjournals.org/content/25/17/3389.full");
#KOBAS
print $output "\n";$writer->emptyTag('ref','id'=>"9",'name'=>"Xie C, Mao X, Huang J, et al. KOBAS 2.0: a web server for annotation and identification of enriched pathways and diseases[J]. Nucleic acids research, 2011, 39(suppl 2): W316-W322.",'link'=>"http://nar.oxfordjournals.org/content/39/suppl_2/W316.short");
#HMM
print $output "\n";$writer->emptyTag('ref','id'=>"10",'name'=>"Eddy S R. Profile hidden Markov models[J]. Bioinformatics, 1998, 14(9): 755-763.",'link'=>"http://bioinformatics.oxfordjournals.org/content/14/9/755.short");
#ARDB
print $output "\n";$writer->emptyTag('ref','id'=>"11",'name'=>"Liu B, Pop M. ARDB—antibiotic resistance genes database[J]. Nucleic acids research, 2009, 37(suppl 1): D443-D447.",'link'=>"http://nar.oxfordjournals.org/content/37/suppl_1/D443.abstract");
#CARD
print $output "\n";$writer->emptyTag('ref',id=>'12','name'=>"Arango-Argoty G, Singh G, Heath L S, et al. MetaStorm: A Public Resource for Customizable Metagenomics Annotation[J]. Plos One, 2016, 11(9):e0162442.",'link'=>"https://www.researchgate.net/publication/308174735_MetaStorm_A_Public_Resource_for_Customizable_Metagenomics_Annotation");
#CAZyme
print $output "\n";$writer->emptyTag('ref','id'=>"13",'name'=>"Yin Y, Mao X, Yang J, et al. dbCAN: a web resource for automated carbohydrate-active enzyme annotation[J]. Nucleic acids research, 2012, 40(W1): W445-W451.",'link'=>"http://nar.oxfordjournals.org/content/40/W1/W445.long");
#matbat
print $output "\n";$writer->emptyTag('ref','id'=>"14",'name'=>"Dongwan D. Kang, Jeff Froula , Rob Egan and Zhong Wang: MetaBAT, an efficient tool for accurately reconstructing single genomes from complex microbial communitie.",'link'=>"https://peerj.com/articles/1165/");
#bowtie2
print $output "\n";$writer->emptyTag('ref','id'=>"14",'name'=>"Langmead B, Wilks C, Antonescu V, Charles R. Scaling read aligners to hundreds of threads on general-purpose processors. Bioinformatics. 2018 Jul 18. doi: 10.1093/bioinformatics/bty648.",'link'=>"https://academic.oup.com/bioinformatics/advance-article/doi/10.1093/bioinformatics/bty648/5055585");
#bowtie
print $output "\n";$writer->emptyTag('ref','id'=>"14",'name'=>"Langmead B, Trapnell C, Pop M, Salzberg SL. Ultrafast and memory-efficient alignment of short DNA sequences to the human genome. Genome Biol 10:R25.",'link'=>"https://genomebiology.biomedcentral.com/articles/10.1186/gb-2009-10-3-r25");
=cut



