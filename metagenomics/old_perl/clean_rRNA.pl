#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use FindBin qw($Bin);
use Getopt::Long;
use Cwd 'abs_path';
my $sortmerna="/local_data1/software/SortMeRNA/sortmerna-2.1b";
my $shuffle_fq="/local_data1/software/velvet/velvet-1.2.10/contrib/shuffleSequences_fasta/shuffleSequences_fastq.pl";
my $split="$sortmerna/scripts/unmerge-paired-reads.sh";
my $seqtk="/local_data1/software/seqtk/seqtk";
my $qsub="/home/fanyucai/software/qsub/qsub-pbs.pl";
my(@pe1,@pe2,$outdir,@prefix,$queue);
$queue||="cu";
$outdir||=getcwd;
GetOptions(
    "pe1:s{1,}"=>\@pe1,      
    "pe2:s{1,}"=>\@pe2,
    "o:s"=>\$outdir,
    "p:s{1,}"=>\@prefix,
    "q:s"=>\$queue,
           );
sub usage{
    print qq{
This script will filter ribosomal RNA sequences use  sortmerna.
usage:
perl $0 -pe1 sample1_1.fq sample2_1.fq -pe2 sample1_2.fq sample_2_2.fq -o $outdir -p p1 p2
options:
-pe1                   5' reads fastq several split by space (force)
-pe2                   3' reads fastq several split by space (froce)
-o                     output of directory(defualt:$outdir)
-p                     the prefix of output several split by space  (froce)
-q                     which queue you run(defualt:$queue)
Email:fanyucai1\@126.com
2018.8.17
    };
    exit;
}

if(!@pe1 || !@pe2 ||!@prefix)
{
    &usage();
}
system "mkdir -p $outdir/";
open(SH,">$outdir/clean_rRNA.sh");
for (my $i=0;$i<=$#pe1;$i++)
{
    $pe1[$i]=abs_path($pe1[$i]);
    $pe2[$i]=abs_path($pe2[$i]);
    print SH "$seqtk mergepe $pe1[$i] $pe2[$i] >$outdir/$prefix[$i].fq && cd $outdir/ && ";
    print SH "$sortmerna/sortmerna --ref $sortmerna/rRNA_databases/silva_merge.fasta,$sortmerna/index/silva_merge.idx -a 30 --reads $outdir/$prefix[$i].fq --paired_out --num_alignments 1 --fastx --aligned $prefix[$i]\_rRNA  --other $prefix[$i]\_no_rRNA && ";
    print SH "$split $outdir/$prefix[$i]\_no_rRNA.fq $outdir/$prefix[$i]\_1.fq $outdir/$prefix[$i]\_2.fq && rm -rf $outdir/$prefix[$i].fq $outdir/$prefix[$i]\_no_rRNA.fq $outdir/$prefix[$i]\_rRNA.fq\n";
}
system "perl $qsub --queue $queue $outdir/clean_rRNA.sh";
