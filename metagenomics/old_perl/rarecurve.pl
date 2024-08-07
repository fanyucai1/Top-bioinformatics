#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin qw($Bin);
use Cwd;
use Getopt::Long;

my $R="/allwegene1/work/fanyucai/software/R/R-v3.2.4/bin/Rscript";
my ($table,$outdir);
GetOptions(
    "table:s"=>\$table,
    "o:s"=>\$outdir,
);
sub usage{
    print qq {
This script will plot rare curve use vegan.
usage:
perl $0 -table otu.table -o /path/to/directory/
options:
-table              OTU table
-o                  output directory
-xlab               xlab name
-ylab               ylab name
Email:fanyucai1\@126.com
2016.1.11
    };
    exit;
}
if (!$table||!$outdir)
{
    &usage();
}
#############################################Species Accumulation Curves and Rarefaction Species Richness
open(EXP,">$outdir/rarecurve.Rscript");
print EXP "#!$R
library(vegan)
x=read.table(\"$table\",sep=\"\\t\",header=T,row.names=1)
y=t(x)
png(\"$outdir/rarecurve.png\",res=300,height=2000,width=2000)
rarecurve(y, step = 2, col = rainbow(nrow(y)), cex = 0.6 ,xlab = \"Sequencing_Reads_Numbers\", ylab = \"No. of species\")
dev.off()";
system "$R $outdir/rarecurve.Rscript";