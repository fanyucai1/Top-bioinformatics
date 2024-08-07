#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
my (@pe1,@pe2,$outdir,@prefix,$job,$queue);
my $trim="/allwegene3/soft/public/16s/Trimmomatic-0.33/Trimmomatic-0.33/trimmomatic-0.33.jar";
my $qsub="/allwegene3/work/jianghao/qsub_sge.pl";
my $len||=150;
$queue||="big.q";
$job||=10;
GetOptions(
    "pe1:s{1,}"=>\@pe1,
    "pe2:s{1,}"=>\@pe2,
    "p:s{1,}"=>\@prefix,
    "o:s"=>\$outdir,
    "minL:s"=>\$len,
    "job:s"=>\$job,
    "queue:s"=>\$queue,
);
sub usage{
    print qq{
This script will quality control fastq file.
usage:
perl $0 -pe1 sample1_1.fq sample2_1.fq -pe2 sample1_2.fq sample2_2.fq -o /path/to/outdir/ -p sample1 sample2 -minL 150
Options:
-pe1            5' reads(many files split by space)
-pe2            3'reads(many files split by space)
-o              output directory
-p              the prefix of output(many files split by space)
-minL           min length of quality control(default:150)
-job						set the maximum number of process in queue, default 20
-queue					specify the queue to use, default blade.q
Email:fanyucai1\@126.com
2016.12.28
version:2.0
This parameter from paper:: Evaluation of shotgun metagenomics sequence classification methods using in silico and in vitro simulated communities.
    };
    exit;
}
if(!@pe1 || !@prefix || !$outdir)
{
    &usage();
}
system "mkdir -p $outdir/";
open(QC,">$outdir/trimmomatic.sh");
for (my $k=0;$k<=$#pe1;$k++)
{
	print QC "java -jar  -Xmx10g $trim PE -threads 15  $pe1[$k] $pe2[$k] $outdir/$prefix[$k]\_1.fq  $outdir/$prefix[$k]\_1_un.fq $outdir/$prefix[$k]\_2.fq $outdir/$prefix[$k]\_2_un.fq CROP:$len ILLUMINACLIP:/allwegene2/software/RNA/QC/Trimmomatic-0.33/adapters/customed_adapter.fa:2:30:10 SLIDINGWINDOW:15:20 TRAILING:15 LEADING:20 MINLEN:$len && ";
	print QC "rm $outdir/$prefix[$k]\_1_un.fq $outdir/$prefix[$k]\_2_un.fq\n";
}
`perl $qsub --maxproc $job --queue $queue $outdir/trimmomatic.sh`;
print "Quality_control run done\n";
