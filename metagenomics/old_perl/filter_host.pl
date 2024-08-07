#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;

my ($host,$outdir,@pe1,@pe2,@prefix);
my $bowtie2="/home/fanyucai/software/bowtie2/bowtie2-2.2.9/bowtie2";
my $qsub="/home/fanyucai/software/qsub/qsub-pbs.pl";
my $thread||=10;
my $mismatch||=2;
my $queue||="all";
my $job||=20;
$outdir||=getcwd;
GetOptions(
    "host:s"=>\$host,
    "o:s"=>\$outdir,
    "pe1:s{1,}"=>\@pe1,
    "pe2:s{1,}"=>\@pe2,
    "t:s"=>\$thread,
    "n:s"=>\$mismatch,
    "p:s{1,}"=>\@prefix,
    "job:s"=>\$job,
    "queue:s"=>\$queue,
        );
sub usage
{
    print qq{
This script use bowtie filter the host sequence.
usage:
perl $0 -host host_bowtie.index -o /path/to/directory -pe1 sample1.1.fq sample2.1.fq -pe2 sample1.2.fq sample2.2.fq -t 5 -p sample1 sample2 -n 2
options:
-host           the host index use bowtie-build:force
-pe1            the sample pe1 fastq(force,many files split by space)
-pe2            the sample pe2 fastq(force,many files split by space)
-t              the thread number(default:10)
-p              the prefix of output(force)
-n              the mismatch in mapping(default:2)

This parameter of process is from paper named: Gut metagenome in European women with normal, impaired and diabetic glucose control
Email:fanyucai1\@126.com
2016.12.29
version:2.0
    };
    exit;
}

if (!@pe1 || !@pe2 || !@prefix)
{
    &usage();
}
open(FL,">$outdir/filter_host.sh");
for(my $k=0;$k<=$#prefix;$k++)
{
	print FL "$bowtie2 --no-head --very-sensitive-local --un-conc $outdir/$prefix[$k].fq --threads $thread -x $host -1 $pe1[$k] -2 $pe2[$k] -S $outdir/$prefix[$k].sam && rm $outdir/$prefix[$k].sam\n";
}
`perl $qsub --maxproc $job --queue $queue $outdir/filter_host.sh`;
print "Filter_host run done\n";
