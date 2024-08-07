#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use FindBin qw($Bin);

my (@pe1,@pe2,$outdir,@prefix,$size);
$size||=30;
my $metaphlan="/allwegene1/work/fanyucai/software/metaphlan/metaphlan2/";
my $metaphlan1="/allwegene1/work/fanyucai/software/metaphlan/metaphlan_v1/";
my $python="/allwegene1/work/fanyucai/software/python/Python-v2.7.12/bin/python";
my $shuffle2fq="/allwegene1/work/fanyucai/metagenomics/sub/shuffleSequences_fastq.pl";
my $db="/allwegene1/work/fanyucai/software/metaphlan/metaphlan2/db_v20/mpa_v20_m200";
my $graphlan="/allwegene1/work/fanyucai/software/graphlan/";
my $krona="/allwegene1/work/fanyucai/software/KronaTools/KronaTools-2.7/bin";
my $bowtie2="/allwegene2/software/RNA/Map/bowtie2-2.2.6/bowtie2";
my $samtools="/allwegene2/software/PUBLIC/NGS_general/samtools-1.3/samtools";
my $bam_script="/allwegene1/work/fanyucai/script/bam_statistics.pl";
GetOptions(
    "pe1:s{1,}"=>\@pe1,
    "pe2:s{1,}"=>\@pe2,
    "o:s"=>\$outdir,
    "size:s"=>\$size,
    "p:s{1,}"=>\@prefix, 
);

sub usage{
    print qq{
#https://bitbucket.org/biobakery/metaphlan2
This script will map clean data to taxon database use metaphlan.
usage:
perl $0 -pe1 a_1.fq b_1.fq -pe2 a_2.fq b_2.fq -o /path/to/directory -p a b
options:
-pe1            the 5' reads of PE reads
-pe2            the 3' reads of PE reads
-size            the size of the output image(default:30)
-p                the prefix of output
-o                the output directory
Email:fanyucai1\@126.com
2016.12.29
version:2.0
    };
    exit;
}
sub qsub()
{
	my ($shfile, $queue, $ass_maxproc) = @_ ;
    $queue||="all.q";
    $ass_maxproc||=5;
    my $cmd = "perl /allwegene1/work/fanyucai/bin/qsub_sge.pl --maxproc $ass_maxproc --queue $queue --resource vf=15G --reqsub $shfile --independent" ;
    my $flag=system($cmd);
    if($flag !=0)
    {
		die "qsub [$shfile] die with error : $cmd \n";
        exit;
	}
}
if(!@pe1 ||!@pe2||!$outdir||!@prefix)
{
    &usage();
}
system "mkdir -p $outdir/";
open(TAX,">$outdir/tax.sh");
my ($ket,$meta,$bamfile);
for (my $k=0;$k<=$#pe1;$k++)
{
    print TAX "perl $shuffle2fq  $pe1[$k] $pe2[$k] $outdir/$prefix[$k].fastq  && ";
    print TAX "$bowtie2 --very-sensitive -S $outdir/$prefix[$k].sam -x $db -U $outdir/$prefix[$k].fastq && ";
    print TAX "$samtools view -Sb $outdir/$prefix[$k].sam -o $outdir/$prefix[$k].bam && $samtools sort $outdir/$prefix[$k].bam -o $outdir/$prefix[$k]_sort.bam && ";
    print TAX "$python  $metaphlan/metaphlan2.py  $outdir/$prefix[$k].sam  --input_type sam > $outdir/$prefix[$k].xls && rm $outdir/$prefix[$k].fastq && ";
    print TAX "$python $metaphlan/utils/metaphlan2krona.py -p $outdir/$prefix[$k].xls -k $outdir/$prefix[$k]_krona.txt && ";
    print TAX  "sed 1d $outdir/$prefix[$k].xls > $outdir/$prefix[$k].txt && $python $metaphlan1/plotting_scripts/metaphlan2graphlan.py  $outdir/$prefix[$k].txt  --tree_file $outdir/$prefix[$k].tree.txt --annot_file $outdir/$prefix[$k].annot.txt && ";
    print TAX "$graphlan/graphlan_annotate.py --annot $outdir/$prefix[$k].annot.txt  $outdir/$prefix[$k].tree.txt $outdir/$prefix[$k].xml && ";
    print TAX "$graphlan/graphlan.py --dpi 300 $outdir/$prefix[$k].xml $outdir/$prefix[$k].png --format png && rm -rf  $outdir/$prefix[$k].txt  $outdir/$prefix[$k].bam  $outdir/$prefix[$k].sam\n";
    $ket.="$outdir/$prefix[$k]_krona.txt ";
    $bamfile.="$outdir/$prefix[$k]_sort.bam ";
    $meta.="$prefix[$k] ";
}
&qsub("$outdir/tax.sh");
open(TAXX,">$outdir/tax2.sh");
if($#pe1>0)
{
    print TAXX "$krona/ktImportText $ket -o $outdir/all_sample.krona.html && ";
    print TAXX "rm -rf $outdir/mapped_ratio.xls && $metaphlan/utils/merge_metaphlan_tables.py  $outdir/*xls >  $outdir/merged_abundance_table.txt && ";
    print TAXX "$metaphlan/utils/metaphlan_hclust_heatmap.py -c bbcry --top 25 --minv 0.1 -s log --in $outdir/merged_abundance_table.txt  --out $outdir/abundance_heatmap.png && ";
    print TAXX "sed 1,2d $outdir/merged_abundance_table.txt >$outdir/temp.txt  && $python $metaphlan1/plotting_scripts/metaphlan2graphlan.py  $outdir/temp.txt  --tree_file $outdir/merged.tree.txt --annot_file $outdir/merged.annot.txt && ";
    print TAXX "$graphlan/graphlan_annotate.py --annot $outdir/merged.annot.txt  $outdir/merged.tree.txt $outdir/merged.xml && ";
    print TAXX "$graphlan/graphlan.py --dpi 300 $outdir/merged.xml $outdir/merged.png  --format png && ";
}
print TAXX "perl $bam_script -bam $bamfile -p $meta -o $outdir/";
if($#pe1==0)
{
    print TAXX "$krona/ktImportText $ket -o $outdir/all_sample.krona.html";
}
&qsub("$outdir/tax2.sh");
