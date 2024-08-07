#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin qw($Bin);
use Getopt::Long;
use Cwd;

my $Rscript="/allwegene1/work/fanyucai/software/R/R-v3.2.4/bin/Rscript";
my($outdir,$count,$group,$prefix);
$outdir||=getcwd;

GetOptions(
	"count:s"=>\$count,
	"o:s"=>\$outdir,
	"group:s"=>\$group,
	"p:s"=>\$prefix,
);
sub usage{
	print qq {
This script analysis of similarities (ANOSIM) provides a way to test statistically whether there is a significant difference between two or more groups of sampling units.	
usage:
perl $0 -count count.txt -o /path/to/directory/ -p prefix1 -group group.txt
options:
-count(force)	the count table like this(one row is a sample):
						################################
						spe1	spec2	spec3
						1	2	3
						4	5	6
						7	8	9
						###################################
-group(force)	the txt file(the group corrspoding the sample) like this:
						###########################
						sample_ID	group1	group2
						sample1	class1	class1
						sample2	class2	class1
						sample3	class2	class1
						sample4	class1	class2
						############################
-o	output directory(force)
-p	the prefix of output(force),this prefix corresponding in the group file

Email:fanyucai1\@126.com
2017.1.3		
};
	exit;
	}
if(!$group || !$count||!$prefix||!$outdir)
{
	&usage();
}
##################################get the sample count per species
open(COU,"$count");
my (%hash,@sample,$num,@spec);
$num=-1;
while(<COU>)
{
	chomp;
	my @array=split(/\t/,$_);
	if($num==-1)
	{
		for(my $j=1;$j<=$#array;$j++)
		{
			$sample[$j-1]=$array[$j];
		}
	}
	else
	{
		$spec[$num]=$array[0];
		for(my $j=1;$j<=$#array;$j++)
		{
			$hash{$spec[$num]}{$sample[$j-1]}=$array[$j];
		}
	}
	$num++;
}
#####################################get the sample order
open(GR,"$group");
my $pos;
my $line=-1;
my @seq;
while(<GR>)
{
	chomp;
	my @array=split;
	if($line==-1)
	{
		for(my $k=1;$k<=$#array;$k++)
		{
			if($array[$k] eq $prefix)
			{
				$pos=$k;
			}
		}
	}
	else
	{
		$seq[$line]=$array[0];
	}
		$line++;
}
############################output

open(TMP,">$outdir/$prefix.temp.txt");
for(my $k=0;$k<=$#spec-1;$k++)
{
	print TMP "spec.$k;";
}
my $numm=$#spec;
print TMP "spec.$num";

for(my $n=0;$n<=$#seq;$n++)
{
	print TMP "\n";
	for(my $k=0;$k<=$#spec-1;$k++)
	{
		print TMP "$hash{$spec[$k]}{$seq[$n]};";
	}
	print TMP "$hash{$spec[$#spec]}{$seq[$n]}";
}
close TMP;
###########################

open(R,">$outdir/$prefix.anosim.Rscript");
print R "\#!$Rscript\n";
print R "count=read.table(\"$outdir/$prefix.temp.txt\",header=T,sep=\"\;\",fileEncoding = \"UTF-8\")
group=read.table(\"$group\",header=T,sep=\"\\t\")
attach(group)
library(\"vegan\")
dune.dist=vegdist(count,method=\"bray\")
dune.ano <- anosim(dune.dist, $prefix)
png(\"$outdir/$prefix.anosim.png\",res=300,width=1500,height=1500)
plot(dune.ano)
dev.off()
";

`$Rscript $outdir/$prefix.anosim.Rscript`;