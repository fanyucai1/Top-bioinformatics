#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;

my $megahit="/allwegene1/work/fanyucai/software/megahit/megahit-master/megahit";#v1.0.6
my $fastuniq="/allwegene2/software/PUBLIC/FastUniq-1.1/fastuniq";
my $qsub="/allwegene1/work/fanyucai/software/qsub/qsub_sge.pl";

my (@pe1,@pe2,$outdir,$minlength,@prefix,$presets);
$minlength||=500;
my $thread||=50;
GetOptions(
    "o:s"=>\$outdir,
    "pe1:s{1,}"=>\@pe1,
    "pe2:s{1,}"=>\@pe2,
    "p:s{1,}"=>\@prefix,
    "t:s"=>\$thread,
    "presets:s"=>\$presets,
    "l:s"=>\$minlength,#This parameter is from paper named:A human gut microbial gene catalogue established by metagenomic sequencing.
);
sub usage{
    print qq{
This script will run the metagenomic assembly use megahit.
usgae:
perl $0 -pe1 sample1_1.fq sample2_1.fq -pe2 sample1_2.fq sample2_2.fq -l 500 -t 50 -o /path/to/directory -p sample1 sample2
options:
-pe1         paired-end #1 files, paired with files in <pe2> (space-separated)  
-pe2         paired-end #2 files, paired with files in <pe1> (space-separated)      
-l           minimum length of contigs to output [500]
-t           number of CPU threads, at least 2 if GPU enabled(default:20)
-o           output directory
-p           the prefix of output corresponding of samples number(space-separated)
-presets 		override a group of parameters; possible values:
                                            meta: '--min-count 2 --k-min 21 --k-max 99 --k-step 20'
                                            (generic metagenomes, default)
                                            meta-sensitive: '--min-count 2 --k-min 21 --k-max 99 --k-step 10'
                                            (more sensitive but slower)
                                            meta-large: '--min-count 2 --k-min 27 --k-max 87 --k-step 10'
                                            (large & complex metagenomes, like soil)
                                            bulk: '--min-count 3 --k-min 21 --k-max 121 --k-step 10 --prune-level 3'
                                            (experimental, standard bulk sequencing)
                                            single-cell: '--min-count 3 --k-list 21,33,55,77,99,121 --merge-level 20,0.96'
                                            (experimental, single cell data)

Email:fanyucai1\@126.com
2016.12.29
version:2.0
    };
    exit;
}
if(!@pe1||!@pe2||!@prefix||!$outdir)
{
    &usage();
}
sub qsub()
{
    my ($shfile, $queue, $ass_maxproc) = @_ ;
    $queue||="all.q";
    $ass_maxproc||=15;
    my $cmd = "perl $qsub --maxproc $ass_maxproc --queue $queue --resource vf=15G --reqsub $shfile --independent" ;
    my $flag=system($cmd);
    if($flag !=0)
    {
		die "qsub [$shfile] die with error : $cmd \n";
        exit;
	}
}
###################step1: Duplicates Removal Tool use fastuniq( refernce paper:Metagenome-assembled genomes uncover a global brackish microbiome)
#my @array=split(/\s+/,@pe1);
open(FAST,">$outdir/fastuniq.sh");
my ($metape1,$metape2);
for (my $k=0;$k<=$#pe1;$k++)
{
    system "echo $pe1[$k]  >$outdir/list.$k";
    system "echo $pe2[$k] >>$outdir/list.$k";
    print FAST "$fastuniq -i $outdir/list.$k -o $outdir/$prefix[$k]\_1.fq -p $outdir/$prefix[$k]\_2.fq -t q\n";
    $metape1.="$outdir/$prefix[$k]\_1.fq,";
    $metape2.="$outdir/$prefix[$k]\_2.fq,";
}
chop($metape1);
chop($metape2);
&qsub("$outdir/fastuniq.sh");
###################step2:assembly use megahit
if($#pe1<=100)
{
    if($#pe1<5)
    {
    	system "echo '$megahit -1 $metape1 -2 $metape2 --presets meta-sensitive  --min-contig-len $minlength -m 0.6 -t $thread -o $outdir/megahit'>$outdir/megahit.sh";
    }
    elsif($#pe1>=5 && $#pe1<=10)
    {
    	system "echo '$megahit -1 $metape1 -2 $metape2 --presets meta --min-contig-len $minlength  -m 0.6 -t $thread -o $outdir/megahit'>$outdir/megahit.sh";
    }
    elsif($#pe1>10 && $#pe1<15)
    {
    	system "echo '$megahit -1 $metape1 -2 $metape2 --presets meta-large --min-contig-len $minlength  -m 0.6 -t $thread -o $outdir/megahit'>$outdir/megahit.sh";
    }
    else
    {
    	system "echo '$megahit -1 $metape1 -2 $metape2 --presets bulk --min-contig-len $minlength -m 0.6 -t $thread -o $outdir/megahit/'>$outdir/megahit.sh";
    }
}
&qsub("$outdir/megahit.sh","big.q");
