#!/usr/bin/perl -w
use strict;
use warnings;
use FindBin qw($Bin);
use Getopt::Long;
use Cwd;
my $qsub="/allwegene3/work/jianghao/qsub_sge.pl";
my $diamond="/allwegene3/work/fanyucai/software/diamond/diamond";
my $nr_index="/allwegene3/database/diamond_index/nr";
my $Viruses_index="/allwegene3/database/diamond_index/Viruses";
my $idba_ud="/allwegene3/work/fanyucai/software/IDBA/idba-master/bin";
my $blast2lca="/allwegene3/work/fanyucai/software/MEGAN/megan6/tools/blast2lca";
my $g2t="/allwegene3/work/fanyucai/software/MEGAN/prot-gi2tax-August2016X.bin";
my $a2t="/allwegene3/work/fanyucai/software/MEGAN/prot_acc2tax-Oct2017X1.abin";
my $R="/allwegene3/soft/public/R/R-v3.3.1/bin/";
my $metaphlan="/allwegene3/work/fanyucai/software/metaphlan/metaphlan2/";
my $lefse="/allwegene3/work/fanyucai/metagenomics/sub/lefse.pl";
my $xvf_run="xvfb-run"; ## usr/bin/xvfb-run
my($outdir,@prefix,@pe1,@pe2,@fa,$num,$type,$index,$queue,$db,@class,@subclass,$task_num);

GetOptions(
     "pe1:s{1,}"=>\@pe1,
     "pe2:s{1,}"=>\@pe2,
     "fa:s{1,}"=>\@fa,
     "p:s{1,}"=>\@prefix,
     "o:s"=>\$outdir,
     "n:s"=>\$num,
     "t:s"=>\$type,
     "task:i"=>\$task_num,
     "queue:s"=>\$queue,
     "class:s{1,}"=>\@class,
     "subclass:s{1,}"=>\@subclass,
           );
$num ||=15;
$type||="nr";
$task_num||=6;
$queue||='big.q';
if($type =~/Viruses/i)
{
    $index=$Viruses_index;
}
else
{
    $index=$nr_index;
}
sub qsub()
{
    my ($shfile, $queue, $ass_maxproc) = @_ ;
    $queue||="big.q";
    $ass_maxproc||=6;
    my $cmd = "perl $qsub --maxproc $ass_maxproc --queue $queue --resource vf=15G --reqsub $shfile --independent" ;
    my $flag=system($cmd);
    if($flag !=0)
    {
		die "qsub [$shfile] die with error : $cmd \n";
        exit;
	}
}
sub usage{
    print qq{
 #https://github.com/bbuchfink/diamond
 This script will map clean data(or fasta file) to nr database by diamond and  parse species abudance.
 
 usage:
 perl $0 -pe1 sample1_1.fq sample2_1.fq -pe2 sample1_2.fq sample2_2.fq  -o /path/to/directory -p sample1 sample2 -t Viruses
 or
 perl $0 -fa input.fa -o /path/to/directory -p prefix -t nr
 or
 perl $0 -pe1 s1_1.fq s2_1.fq s3_1.fq s4_1.fq s5_1.fq s6_1.fq -pe2 s1_2.fq s2_2.fq s3_2.fq s4_2.fq s5_2.fq s6_2.fq -class c1 c1 c1 c2 c2 c2  -o /path/to/directory -p prefix -t nr
 or
 perl $0 -pe1 s1_1.fq s2_1.fq s3_1.fq s4_1.fq s5_1.fq s6_1.fq -pe2 s1_2.fq s2_2.fq s3_2.fq s4_2.fq s5_2.fq s6_2.fq -class c1 c1 c1 c2 c2 c2 -subclass c1 c1 c2 c2 c3 c3 -o /path/to/directory -p prefix -t nr
 
options:
-pe1                    5' read
-pe2                    3' read
-p                      the prefix of output(force)
-o                      output directory(force)
-n                      the threads every task.
-fa                     input fasta file
-t                      the type of database:nr or Viruses(defualt:nr)
-class			the group of samples
-suclass		the sub class of samples
-queue			set the queue.default big.q.
-task			set the num of tasks onece proceing.
 2018.09.06
 version2.1
Buchfink B, Xie C, Huson D H. Fast and sensitive protein alignment using DIAMOND[J]. Nature methods, 2015, 12(1): 59-60.
    };
    exit;
}
if(!@prefix||!$outdir)
{
    &usage();
}
system "mkdir -p $outdir/";
if(@pe1 && @pe2)
{
    open(D1,">$outdir/diamond1.sh");
    for(my $k=0;$k<=$#prefix;$k++)
    {
        print D1 "$idba_ud/fq2fa --merge $pe1[$k] $pe2[$k] $outdir/$prefix[$k].fa && $diamond blastx -q $outdir/$prefix[$k].fa -d $index -p $num --top 1 -k 1 --outfmt 100 -e 0.00001 -o $outdir/$prefix[$k].daa\n";
    }
    &qsub("$outdir/diamond1.sh",$queue,$task_num);
}

if(@fa)
{
    open(D1,">$outdir/diamond1.sh");
    for(my $k=0;$k<=$#prefix;$k++)
    {
        print D1 "$diamond blastx -q $fa[$k] -d $index -p $num --top 1 -k 1 --outfmt 100 -e 0.00001 -o $outdir/$prefix[$k].daa\n";
    }
    &qsub("$outdir/diamond1.sh",$queue,$task_num);
}
open(D2,">$outdir/diamond2.sh");
for(my $k=0;$k<=$#prefix;$k++)
{
    if($type eq "nr")
    {
            print D2 "$xvf_run -a --auto-servernum --server-num=1  $blast2lca -g2t $g2t -i $outdir/$prefix[$k].daa -o $outdir/$prefix[$k].tax.out\n";
    }
    else
    {
            print D2 "$xvf_run -a --auto-servernum --server-num=1  $blast2lca -a2t $a2t -i $outdir/$prefix[$k].daa -o $outdir/$prefix[$k].tax.out\n";
    }
 }
&qsub("$outdir/diamond2.sh",$queue,$task_num);
open(DE,">$outdir/diamond.total.xls");
print DE "ID\tTotal_numbers\tBacterial\tArchaea\tEukaryota\tViruses\tPhage\n";
my (%hasht,@depth,@unclass);
if(-e "$outdir/depth.txt")
{
	open(DEPTH,"$outdir/depth.txt");
	while(<DEPTH>)
	{
		chomp;
		@depth=split(/ /,$_);
	}
}
else
{
    open(DEPTH,">$outdir/depth.txt");
    for(my $k=0;$k<=$#prefix;$k++)
    {
	my ($total,@arr);
    	if($pe1[$k])
    	{
	    $total=`wc -l $pe1[$k]`;
	    chomp($total);
	    @arr=split(/ /,$total);
	    $arr[0]=$arr[0]/2;
	    $depth[$k]=$arr[0];
    	}
    	if($fa[$k])
    	{
	    $total=`grep -c \\> $fa[$k]`;
	    chomp($total);
	    $depth[$k]=$total;
    	}
	if ($k==$#prefix)
	{
	    print DEPTH "$depth[$k]";
	}
	else
	{
	    print DEPTH "$depth[$k] ";
	}
    }
}
for (my $k=0;$k<=$#prefix;$k++)
{
    open(IN,"$outdir/$prefix[$k].tax.out");
    my($blast,$Viruses,$tax,$Bacteria,$Archaea,$Eukaryota,$phage);
    $Viruses||=0;
    $Bacteria||=0;
    $Archaea||=0;
    $Eukaryota||=0;
    $phage||=0;
    TR:while(<IN>)
    {
        chomp;
        my @array=split(/;/,$_);
	my $string;
	for(my $k=2;$k<=$#array;$k=$k+2)
	{
	    if ($k==2)
	    {
		$array[2]=~s/d__/k__/;
		$string=$array[2];
	    }
	    else
	    {
		$string.="\|$array[$k]";
	    }
	}
    	if($_=~/Bacteria/i)
        {
            $Bacteria++;
            $hasht{$string}{$prefix[$k]}++;
	    next TR;
        }
        if($_=~/Archaea/i)
        {
            $Archaea++;
            $hasht{$string}{$prefix[$k]}++;
	    next TR;
        }
        if($_=~/Eukaryota/i)
        {
            $Eukaryota++;
            $hasht{$string}{$prefix[$k]}++;
	    next TR;
        }
        if($_=~/virus/i)
        {
            $Viruses++;
            $hasht{$string}{$prefix[$k]}++;
	    next TR;
        }
        if($_=~/phage/i)
        {
            $phage++;
            $hasht{$string}{$prefix[$k]}++;
	    next TR;
        }
        $blast++;
    }
    $hasht{"un"}{$prefix[$k]}=$depth[$k]-$Bacteria-$Archaea-$Eukaryota-$Viruses-$phage;
    print DE "$prefix[$k]\t$depth[$k]\t$Bacteria\t$Archaea\t$Eukaryota\t$Viruses\t$phage\n";
}

open(TABLE1,">$outdir/raw.diamond.xls");
print TABLE1 "Taxonomy";
for(my $i=0;$i<=$#prefix;$i++)
{
	print TABLE1 "\t$prefix[$i]";
}
foreach my $key(sort { $hasht{$a} <=> $hasht{$b}} keys %hasht)
{
    print TABLE1 "\n$key";
    for(my $i=0;$i<=$#prefix;$i++)
    {
        if(exists $hasht{$key}{$prefix[$i]})
        {
            print TABLE1 "\t$hasht{$key}{$prefix[$i]}";
        }
        else
        {
            print TABLE1 "\t0";
        }
    }
}
close TABLE1;
######################################### sample Hierarchical Clustering
if ($#prefix>=2) {
    open(CLU,">$outdir/hcluster.Rscript");
    print CLU "#!$R/Rscript
    library(gplots)
    library(RColorBrewer)
    library(ecodist)
    clust=read.table(\"$outdir/raw.diamond.xls\",header=T,sep=\"\\t\",row.names=1)
    clust.t=t(clust)
    #Bray-Curtis distance
    clust.dist =bcdist(clust.t)
    my_colours <- brewer.pal(8,\"GnBu\")
    png(\"$outdir/hcluster.png\",res=300,width=2000,height=2000)
    heatmap.2(as.matrix(clust.dist), col=my_colours, trace=\"none\")
    dev.off()
    \n";
    `$R/Rscript $outdir/hcluster.Rscript`;
}
#########################################profiles across taxonomy level
if ($#prefix>=1)
{
    open(TAB,"$outdir/raw.diamond.xls");
    my $line=0;
    my %tax;
    my @sample;
    while (<TAB>)
    {
	chomp;
	$line++;
	my @array=split(/\t/,$_);
	if ($line==1)
	{
	    for(my $k=1;$k<=$#array;$k++)
	    {
		$sample[$k-1]=$array[$k];
	    }
	}
	else
	{
	    if ($array[0]!~"\|")
	    {
		for(my $i=1;$i<=$#array;$i++)
		{
		    $tax{$array[0]}{$sample[$i-1]}+=$array[$i];
		}
	    }
	    else
	    {
		my @class=split(/\|/,$array[0]);
		my $temp;
		for (my $k=0;$k<=$#class;$k++)
		{
		    if ($k==0)
		    {
			$temp.=$class[0];
		    }
		    else
		    {
			$temp.="|$class[$k]";
		    }
		    for(my $i=1;$i<=$#array;$i++)
		    {
			$tax{$temp}{$sample[$i-1]}+=$array[$i];
		    }
		}
	    }
	}
    }
    open(HEAT,">$outdir/heatmap.input.xls");
    print HEAT "ID";
    for (my $k=0;$k<=$#sample;$k++)
    {
	print HEAT "\t$sample[$k]";
    }
    foreach my $key (sort { $tax{$a} <=> $tax{$b}}keys %tax)
    {
	if ($key ne "un")
	{
	    print HEAT "\n$key";
	    for (my $k=0;$k<=$#sample;$k++)
	    {
		print HEAT "\t",$tax{$key}{$sample[$k]}/$depth[$k]*1000000;
	    } 
	}
    }
}
###############################################run lefse find important biomarker
if (@class)
{
    open(LEFSE,">$outdir/lefse.input.txt");
    print LEFSE "Class";
    for(my $k=0;$k<=$#class;$k++)
    {	
	print LEFSE "\t$class[$k]";
    }
    print LEFSE "\n";
    if (@subclass)
    {
	print LEFSE "subclass";
	for(my $k=0;$k<=$#class;$k++)
	{
	    print LEFSE "\t$class[$k]";
	}
	print LEFSE "\n";
    }
    `cat $outdir/heatmap.input.xls >>$outdir/lefse.input.txt`;
    open(LEFSE,">$outdir/lefse.sh");
    if (@subclass)
    {
	print LEFSE "perl $lefse -i $outdir/lefse.input.txt -class 1 -subclass 2 -subject 3 -o $outdir -p lefse.diamond -n 1000000";
    }
    else
    {
	print LEFSE "perl $lefse -i $outdir/lefse.input.txt -class 1 -subject 2 -o $outdir -p lefse.diamond -n 1000000";
    }
    &qsub("$outdir/lefse.sh");
}
