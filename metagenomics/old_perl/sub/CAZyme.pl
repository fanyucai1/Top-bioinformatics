#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin qw($Bin);
use Cwd;
use Getopt::Long;
my $CAZyme="/allwegene3/work/fanyucai/metagenomics/CAZyme/";
my $hmmer_dir="/allwegene3/work/fanyucai/software/hmmer/hmmer-v3.1b2/bin";
my $R="/allwegene3/soft/public/R/R-v3.3.1/bin";
my ($non_nucl,$prot,$outdir);

GetOptions(
    "nucl:s"=>\$non_nucl,
    "prot:s"=>\$prot,
    "o:s"=>\$outdir,
);
sub usage{
    print qq{
This script was used to annotate the CAZyme.
usage:
perl $0 -nucl  non-redundant-nucl.fasta -prot  pro.fasta  -o outdir 
options:
-nucl          non redundant nucl gene from cdhit-est
-prot          all protein fasta from metagenemark
-o              the output directory
Email:fanyucai1\@126.com
2016.10.13
    };
    exit;
}
if(!$prot || !$outdir||!$non_nucl)
{
    &usage();
}

open(PP,"$prot");
my (%allp,$name);
while(<PP>)
{
    chomp;
    if($_=~"\>")
    {
        $name=substr($_,1);
    }
    else
    {
        $allp{$name}.=$_;
    }
}

open(PROT,">$outdir/non-redundant-prot.fasta");
open(NUCL,$non_nucl);
while(<NUCL>)
{
    chomp;
    if($_=~/\>/)
    {
        print PROT $_,"\n",$allp{substr($_,1)},"\n";
    }
}
system "mkdir -p $outdir/";
system "ln -s  $CAZyme/* $outdir/";
system "echo 'cd $outdir/ && $hmmer_dir/hmmscan dbCAN-fam-HMMs.txt $outdir/non-redundant-prot.fasta >CAZyme.out'>$outdir/CAZYme.sh";
system "echo 'sh hmmscan-parser.sh CAZyme.out > $outdir/CAZyme.out.ps'>>$outdir/CAZYme.sh";
system "sh $outdir/CAZYme.sh";
my %hash=(
       "PL"=>"PL:Polysaccharide Lyases",
        "GH"=>"GH:Glycoside Hydrolases",
        "GT"=>"GT:Glycosyl Transferases",
         "CE"=>"CE:Carbohydrate Esterases",
          "CBM"=>"CBM:Carbohydrate-Binding Module",
         "AA"=> "AA:Auxiliary Activities"
          );
my %hash2;
open(OUT, "$outdir/CAZyme.out.ps");
while(<OUT>)
{
    if($_=~"PL")
    {
        $hash2{"PL"}++;
    }
    if($_=~"GH")
    {
        $hash2{"GH"}++;
    }
    if($_=~"GT")
    {
        $hash2{"GT"}++;
    }
    if($_=~"CE")
    {
        $hash2{"CE"}++;
    }
    if($_=~"CBM")
    {
        $hash2{"CBM"}++;
    }
    if($_=~"AA")
    {
        $hash2{"AA"}++;
    }
}
open(PLOT,">$outdir/cazyme_R_plot_input.txt");
print PLOT "Class\tCount\tAnno\n";
foreach my $key (keys %hash2)
{
    print PLOT $key,"\t",$hash2{$key},"\t",$hash{$key},"\n";
}

system " echo '
#!$R/Rscript
library(ggplot2)
x=read.table(\"$outdir/cazyme_R_plot_input.txt\",sep=\"\\t\",header=T)
png(\"$outdir/cazyme.png\",width=1800,height=1500,res=300)
ggplot(x,aes(Class,Count,fill=Anno))+geom_bar(stat=\"identity\")
dev.off()
pdf(\"$outdir/cazyme.pdf\")
ggplot(x,aes(Class,Count,fill=Anno))+geom_bar(stat=\"identity\")
dev.off()
'>$outdir/CAZyme.Rscript";

system "$R/Rscript $outdir/CAZyme.Rscript";




