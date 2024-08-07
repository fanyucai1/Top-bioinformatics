#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use FindBin qw($Bin);
my (@pe1,@pe2,$outdir,@sampleID,$prefix,@sam,$fa,@depth,$count);

my $fastq_qc_stat="$Bin/fastq_qc_stat";
my $env="export LD_LIBRARY_PATH=/allwegene1/work/fanyucai/software/gsl/gsl-v1.13/lib:/allwegene1/work/fanyucai/software/R/R-v3.2.4/lib64/R/lib:\$LD_LIBRARY_PATH";
my $sam2count="$Bin/sam2counts.py";
my $python="/allwegene1/work/fanyucai/software/python/Python-v2.7.12/bin/python";
my $trinity="/allwegene2/software/RNA/Assembly/trinityrnaseq_r20140413p1/";
my $qsub="/allwegene1/work/fanyucai/software/qsub/qsub_sge.pl";
GetOptions(
     "pe1:s{1,}"=>\@pe1,       
     "pe2:s{1,}"=>\@pe2,
     "fa:s"=>\$fa,
     "count:s"=>\$count,
     "o:s"=>\$outdir,
     "id:s{1,}"=>\@sampleID,
           );
sub usage{
    print qq{
This script could satistics the PE_fastq file.
usage:
perl $0 -fa gene.fa -pe1 sample1_1.fq sample2_1.fq -pe2 sample1_2.fq sample2_2.fq -id sample1 sample2 -o /path/to/diretory -count count.txt
options:
-pe1        input fastq file,several files split by space(force)
-pe2        input fastq file,several files split by space(force)
-fa       the no-redundant gene
-o        the output directory(force)
-id       sampleID,several IDs split by space(force)
-count    raw count table
Email:fanyucai1\@126.com
2016.12.29
vesion:2.0
    };
    exit;
}
sub qsub()
{
    my ($shfile,$queue,$ass_maxproc)=@_;
    $queue||="big.q";
    $ass_maxproc||=15;
    my $cmd = "perl $qsub --maxproc $ass_maxproc --queue $queue --resource vf=15G --reqsub $shfile --independent" ;
    my $flag=system($cmd);
    if($flag !=0)
    {
		die "qsub [$shfile] die with error : $cmd \n";
        exit;
	}
}
if (!@pe1 || !$outdir||!@sampleID || !@pe2 ||!$count) {
    &usage();
}
open(SAM,">$outdir/noramlize.sh");
#########################read the gene fasta file
open(INN,$fa);
my %hash1;
my $seqname;
while (<INN>)
{
    chomp;
    if ($_=~/^>/)
    {
        $seqname=substr($_,1);
    }
    else
    {
        $hash1{$seqname}.=$_;
    }  
}
################################this process will ouput fastq statistics
my @left=@pe1;
my @id=@sampleID;
open(OUT,">$outdir/statistics_fastq.xls");
print OUT "#Samples\tRead_Number\tBase_Number\tGC_Content(%)\t%>Q20\t%>Q30\n";
my @right=@pe2;
for(my $k=0;$k<=$#left;$k++)
{
    print SAM "$env && $fastq_qc_stat -a $left[$k] -b $right[$k] -f $outdir/$id[$k] -q 100\n";
}
&qsub("$outdir/noramlize.sh");
#`sh $outdir/noramlize.sh`;


for(my $k=0;$k<=$#left;$k++)
{
        my $num=0;
        open(IN, "$outdir/$id[$k].stat") ;
        while (<IN>)
        {
            chomp;
            my @array=split;
            if ($_!~/\#/)
            {
                ++$num;
                if ($num==3)
                {
                    print OUT "$id[$k]\t$array[1]\t$array[2]\t$array[3]\t$array[5]\t$array[7]\n";
                }
            } 
        }
}
close OUT;
open(QC,"$outdir/statistics_fastq.xls");
while(<QC>)
{
    my @array=split;
    if($_!~"#")
    {
        push(@depth,$array[1]);
     }
}
#################################This process  will normalize the count file.(http://2014-5-metagenomics-workshop.readthedocs.io/en/latest/annotation/normalization.html)
open(INN,$count);
open(OUT,">$outdir/normalize_count.xls");
TT:while (<INN>)
{
    chomp;
    my $zero=0;
    my @array=split(/\t/,$_);
    if($_!~"#")
    {
    	for(my $k=1;$k<=$#array;$k++)
    	{
    		if($array[$k] <2)
    		{
    			$zero++;
    			if($zero==$#array)
    			{
    				next TT;
    			}
    		}
    	}
  	}
    if (exists $hash1{$array[0]})
    {
        print OUT "$array[0]";
        for(my $k=1;$k<=$#array;$k++)
        {
            if($array[$k] >=2)#if mapping gene number >=2 this gene will present in a sample
            {
                my $temp1=($array[$k]/$depth[$k-1]*1000000);
                print OUT "\t$temp1";
            }
            else
            {
                print OUT "\t",0;
            }
        }
        print OUT "\n";
    }
    else
    {
        print OUT "$_\n";
    }
}

#########################
                    system "rm $outdir/*.quality";
                    system "rm $outdir/*.acgtn ";
                    system "rm $outdir/*.qstat ";
