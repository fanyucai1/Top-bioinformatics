#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use FindBin qw($Bin);
use Getopt::Long;
my $minNUM=5;
my $kraken="/allwegene1/work/fanyucai/software/kraken/kraken_v0.10.5";
my $kraken_db="/allwegene1/work/fanyucai/software/kraken/minikraken_20141208";
my $R="/allwegene1/work/fanyucai/software/R/R-v3.2.4/bin/";
my $KronaTools="/allwegene1/work/fanyucai/software/KronaTools/KronaTools-2.7/bin";
my $Kronalib="/allwegene1/work/fanyucai/software/KronaTools/KronaTools-2.7/lib";
my $Krona_tax="/allwegene1/work/fanyucai/software/KronaTools/KronaTools-2.7/taxonomy";
my $qsub="/allwegene1/work/fanyucai/software/qsub/qsub_sge.pl";
my $perl="/allwegene2/software/PUBLIC/perl/perl-5.18_multi/bin/perl";
my ($outdir,@prefix,@pe1,@pe2,$class,$subclass);
GetOptions(
       "pe1:s{1,}"=>\@pe1,
       "pe2:s{1,}"=>\@pe2,
       "o:s"=>\$outdir,
       "p:s{1,}"=>\@prefix,
       "class:s"=>\$class,
       "subclass:s"=>\$subclass,
           );
$class||="";
$subclass||="";
sub usage{
    print qq {
This script will mapping reads to microbiome genome use kraken.
usage:
perl $0 -pe1 sample_1.fq  sample2_1.fq -pe2 sample1_2.fq sample2_2.fq -o /path/to/directory -p sample1 sample2 -class c e -subclass c c
options:
-pe1                        5' reads,several split by space
-pe2                        3' reads,several split by space
-o                            output directory
-p                            the prefix of sample,several split by space
-class                      the group corresponding of samples,several split by space
-subclass                subclass,several split by space
Email:fanyucai1\@126.com
2016.12.29
version2.0
    };
    exit;
}
if(!@pe1||!@pe2||!$outdir||!@prefix)
{
    &usage();
    exit;
}
sub qsub()
{
	my ($shfile, $queue, $ass_maxproc) = @_ ;
    $queue||="all.q";
    $ass_maxproc||=5;
    my $cmd = "$perl $qsub --maxproc $ass_maxproc --queue $queue --resource vf=15G --reqsub $shfile --independent" ;
    my $flag=system($cmd);
    if($flag !=0)
    {
		die "qsub [$shfile] die with error : $cmd \n";
        exit;
	}
}
open(CON,">$outdir/kraken2krona.sh");
my ($tt,@depth);
for (my $k=0;$k<=$#pe1;$k++)
{
            if(!-e "$outdir/depth.txt")
            {
                my $string=`wc -l $pe1[$k]`;
                chomp($string);
                my @array=split(/ /,$string);
                $depth[$k]=$array[0]/2;
            }#get the sequencing depth
            print CON "$kraken/kraken --db $kraken_db  --fastq-input --threads 5 --paired $pe1[$k] $pe2[$k] --output $outdir/$prefix[$k]\_kraken.out && ";
            print CON "$kraken/kraken-mpa-report --db $kraken_db $outdir/$prefix[$k]\_kraken.out >$outdir/$prefix[$k].xls && ";
            print CON "cut -f 2,3 $outdir/$prefix[$k]\_kraken.out >$outdir/$prefix[$k].kraken2krona.txt\n";
            $tt.="$outdir/$prefix[$k].kraken2krona.txt ";
}
&qsub("$outdir/kraken2krona.sh");
`echo 'export PERL5LIB=$Kronalib:\$PERL5LIB && $KronaTools/ktImportTaxonomy $tt -o $outdir/all_samples.html' >$outdir/kraken2krona2.sh`;
&qsub("$outdir/kraken2krona2.sh");

 if(!-e "$outdir/depth.txt")
{
    open(DEPTH,">$outdir/depth.txt");
    for(my $k=0;$k<=$#pe1;$k++)
    {
        if($k==$#pe1)
        {
            print DEPTH "$depth[$k]";
        }
        else
        {
            print DEPTH "$depth[$k]\t";
        }
    }
 }
 else
 {
     open(DEPTH,"$outdir/depth.txt");
     while(<DEPTH>)
     {
        chomp;
        @depth=split;
     }
 }
my %heatmap;
open(OUTT1,">$outdir/all.sample.normalize.table.xls");
open(OUTT2,">$outdir/all.sample.raw.table.xls");
if($subclass !~"" )
{
    print OUTT1 "Class\t$class\nSubclass\t$subclass\nSubject";
    print OUTT2 "Class\t$class\nSubclass\t$subclass\nSubject";
}
elsif($class!~"" && $subclass eq "")
{
    print OUTT1 "Class\t$class\nSubject";
    print OUTT2 "Class\t$class\nSubject";
}
else
{
    print OUTT1 "Subject";
    print OUTT2 "Subject";
}
my %taxonomy;
my $num=0;
for (my $k=0;$k<=$#pe1;$k++)
{
    print OUTT1 "\t$prefix[$k]";
    print OUTT2 "\t$prefix[$k]";
    open(INN,"$outdir/$prefix[$k].xls");
    while(<INN>)
    {
        chomp;
        my @array=split;
        $heatmap{$array[0]}{$prefix[$k]}=$array[1];
    }
}
foreach my $key(sort keys %heatmap)
{
    print OUTT1 "\n$key";
    print OUTT2 "\n$key";
    for (my $k=0;$k<=$#pe1;$k++)
    {
        if(exists $heatmap{$key}{$prefix[$k]})
        {
            my $temp=$heatmap{$key}{$prefix[$k]}/$depth[$k];
            print OUTT1 "\t$temp";
            print OUTT2 "\t$heatmap{$key}{$prefix[$k]}";
        }
        else
        {
            print OUTT1 "\t0";
            print OUTT2 "\t0";
        }
    }
}
