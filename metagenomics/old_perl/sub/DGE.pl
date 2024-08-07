#!/usr/bin/perl -w
use strict;
use Cwd;
use Getopt::Long;
use FindBin qw($Bin);

my $trinity="/allwegene3/work/fanyucai/software/trinity/trinityrnaseq-Trinity-v2.3.2/";
#my $env="export LD_LIBRARY_PATH=/allwegene3/work/fanyucai/software/lib:\$LD_LIBRARY_PATH";
my($raw,$normalize,$num,$outdir,$group);
my $FDR||=0.05;
my $Foldchange=2;
$outdir||=getcwd;
GetOptions(
    "r:s"=>\$raw,       
    "n:s"=>\$normalize,       
    "num:s"=>\$num,       
    "o:s"=>\$outdir,
    "g:s"=>\$group,
    "fdr:s"=>\$FDR,
    "f:s"=>\$Foldchange,
           );
sub usage{
    print qq{
 This script will find different abundance gene from raw count and normalize countm using DESeq2.
 usage:
 -r               raw count
 -n               normalize count
 -num             sample number
 -g               tab-delimited text file indicating biological replicate relationships.
#                                   ex.
#                                        cond_A    cond_A_rep1
#                                        cond_A    cond_A_rep2
#                                        cond_B    cond_B_rep1
#                                        cond_B    cond_B_rep2
 -fdr               fdr(default:0.05)
 -f                foldchange(default:2 )
 -o               outputdirectory
 
 Reference paper:
 Jonsson V, …sterlund T, Nerman O, et al. Statistical evaluation of methods for identification of differentially abundant genes in comparative metagenomics[J]. BMC genomics, 2016, 17(1): 1.
    };
    exit;
}
if (!$raw||!$normalize||!$num||!$outdir||!$group)
{
    &usage();
}
system "mkdir -p $outdir/";
open(DGE,">$outdir/DESeq2.sh"); 
print DGE "$trinity/Analysis/DifferentialExpression/run_DE_analysis.pl --matrix $raw --samples_file $group --method DESeq2 --output $outdir/DESeq2/\n";
print DGE "cd $outdir/DESeq2/ && $trinity/Analysis/DifferentialExpression/analyze_diff_expr.pl --matrix $normalize -P $FDR -C $Foldchange --samples $group\n";
`sh $outdir/DESeq2.sh`;
