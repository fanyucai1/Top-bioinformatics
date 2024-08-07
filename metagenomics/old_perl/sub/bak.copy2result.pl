#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use FindBin qw($Bin);
use Getopt::Long;
use Config::IniFiles;
my ($dir,$num,$outdir);

GetOptions(
   "i:s"=>\$dir, 
    "n:s"=>\$num,
    "o:s"=>\$outdir,
);
sub usage{
    print qq{
This script will copy the metagenomics result to html.
usage:
perl -i /path/to/directory -o /path/to/html -n 10
-i                 the output directory of metagenomics analysis(force)
-o                 the backup directory(force)
-n                 the sample number(force)
Email:396041759\@qq.com
2018.04.26
    };
    exit;
}
if(!$num ||!$dir)
{
    &usage();
}

#mkdir pic
system "mkdir -p $outdir/pic";
#system "cp $Bin/kraken.png  $outdir/pic/";
system "cp $Bin/metagenomics.png $outdir/pic/";
system "cp $Bin/shiyan.png $outdir/pic/";


#data_assess
system "mkdir -p $outdir/data_assess/";
system "cp $dir/gene/result/statistics_fastq.xls $outdir/data_assess/";

#assembly
system "mkdir -p $outdir/assembly/";
system "cp $dir/assembly/quast/report.tsv $outdir/assembly/";
system "cp $dir/assembly/contig.fasta $outdir/assembly/";
system "cp $dir/assembly/mapped_ratio.xls $outdir/assembly/";
#gene
system "mkdir -p $outdir/gene/";
system "cp $dir/gene/non-redundant-nucl.fasta $outdir/gene/";
system "cp $dir/CAZyme/non-redundant-prot.fasta $outdir/gene/";
system "cp $dir/gene/result/normalize_count.txt $outdir/gene/";
system "cp $dir/gene/result/raw_count.txt $outdir/gene/raw_count.xls";

#differential gene abundance
if($num>2)
{
    system "cp -r $dir/gene/result/PCA $outdir/gene/";
    system "cp -r $dir/gene/Anosim $outdir/gene/Anosim";
    system "mkdir -p $outdir/DGE";
    system "cp $dir/DGE/*/DESeq2/*.DE_results $outdir/DGE/";
    #system "cp $dir/DGE/edgeR/*.subset $outdir/DGE/";
}
#ARDB
#system "mkdir -p $outdir/ARDB/";
#system "cp $dir/ardb/*xls $outdir/ARDB/";

#card
system "mkdir -p $outdir/card";
system "cp $dir/card/* $outdir/card";
#
#CAZyme
system "mkdir -p $outdir/CAZyme";
system "cp $dir/CAZyme/*pdf  $outdir/CAZyme/";
system "cp $dir/CAZyme/*png  $outdir/CAZyme/";
system "cp $dir/CAZyme/CAZyme.out.ps  $outdir/CAZyme/";
system "cp $dir/CAZyme/CAZyme.out  $outdir/CAZyme/";

#eggNOG
# system "mkdir -p $outdir/eggNOG";

#regualr annotation
system "mkdir -p $outdir/regular_anno/Kegg_map";
system "cp $dir/regular_annotation/Result/*png  $outdir/regular_anno/";
system "cp $dir/regular_annotation/Result/*pdf  $outdir/regular_anno/";
system "cp $dir/regular_annotation/Result/All_Database_annotation.xls  $outdir/regular_anno/";
system "cp $dir/regular_annotation/Result/Function_Annotation.stat.xls  $outdir/regular_anno/";
system "cp $dir/regular_annotation/Result/Integrated_Function.annotation.xls  $outdir/regular_anno/";
system "cp $dir/regular_annotation/Result/*.nr.lib.stat $outdir/regular_anno/";
system "cp $dir/regular_annotation/Result/*.cluster.stat $outdir/regular_anno/";
system "cp $dir/regular_annotation/Result/Kegg_map/* $outdir/regular_anno/Kegg_map/";
system "cp -rf $dir/regular_annotation/Result/each_sample_anno $outdir/regular_anno/";
system "mkdir $outdir/regular_anno/KEGG_wilcoxon_test";
system "cp -rf $dir/regular_annotation/KEGG_Dir/EC $outdir/regular_anno/KEGG_wilcoxon_test";
system "cp -rf $dir/regular_annotation/KEGG_Dir/ko $outdir/regular_anno/KEGG_wilcoxon_test";
system "cp -rf $dir/regular_annotation/KEGG_Dir/gene $outdir/regular_anno/KEGG_wilcoxon_test";

##Taxonomy
#metaphlan
system "mkdir -p $outdir/taxonomy";
system "mkdir -p $outdir/taxonomy/metaphlan/";
system "cp $dir/metaphlan/all_sample.krona.html $outdir/taxonomy/metaphlan/";
system "cp $dir/metaphlan/*png $outdir/taxonomy/metaphlan/";
system "cp $dir/metaphlan/mapped_ratio.xls $outdir/taxonomy/metaphlan/";
if($num>1)
{
    system "cp $dir/metaphlan/merged_abundance_table.txt $outdir/taxonomy/metaphlan/merged_abundance_table.xls";
}

#kraken
=head
system "mkdir -p $outdir/kraken/";
system "cp $dir/kraken/*xls $outdir/kraken/";
system "cp $dir/kraken/*html $outdir/kraken/";
=cut

#diamond
system "mkdir -p $outdir/taxonomy/diamond/";
system "cp $dir/diamond/*xls $outdir/taxonomy/diamond/";
system "cp $dir/diamond/*png $outdir/taxonomy/diamond/";
system "cp $dir/diamond/*pdf $outdir/taxonomy/diamond/";
system "cp $dir/diamond/barplot/*.pdf $outdir/taxonomy/diamond/";
system "cp $dir/diamond/barplot/*.png $outdir/taxonomy/diamond/";
system "cp $dir/diamond/krona/krona.html $outdir/taxonomy/diamond/";

#binning
system "mkdir -p $outdir/binning";
system "cp -r $dir/binning/Result/bins $outdir/binning";

