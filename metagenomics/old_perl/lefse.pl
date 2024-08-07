#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;

my $lefse="/allwegene1/work/fanyucai/software/LEfSe/lefse-2016-08-03";
my $python="/allwegene1/work/fanyucai/software/python/Python-v2.7.12/bin/python";
my $R="/allwegene1/work/fanyucai/software/R/R-v3.2.4/bin/Rscript";
my $metaphlan="/allwegene1/work/fanyucai/software/metaphlan/metaphlan2/";
my($outdir,$input,$prefix,$class,$subclass,$subject,$LDA,$normalize);
$subclass||=-1;
$normalize||=-1;
$LDA||=2;
GetOptions(
    "i:s"=>\$input,       
    "o:s"=>\$outdir,      
    "p:s"=>\$prefix,
    "class:s"=>\$class,
    "subclass:s"=>\$subclass,
    "subject:s"=>\$subject,
    "LDA:s"=>\$LDA,
    "n:s"=>\$normalize,
           );
sub usage{
    print qq{
This script will run lefse based on normalize_count_table.
Usage:
perl $0 -i abundance.txt -o /path/to/directory/ -p prefix -class 1 -subclass 2 -subject 3 -LDA 2
Options:
-i                              count table
-class                          set which feature use as class (default 1)
-subclass                       set which feature use as subclass (default -1 meaning no subclass)
-subject                        set which feature use as subject
-LDA                            set the threshold on the absolute value of the logarithmic LDA score (default 2.0)
-p                              the prefix of output
-o                              out_put_directory
-n                              normalize(default -1.0 meaning no normalization,advise 1000000)
Email:fanyucai1\@126.com
2016.12.22
    };
exit;
}
$outdir||=getcwd;
if(!$outdir||!$prefix||!$class||!$subject)
{
    &usage();
}
system "$lefse/format_input.py $input $outdir/$prefix.in -c $class -s $subclass -u $subject -o $normalize";
system "$lefse/run_lefse.py -l $LDA $outdir/$prefix.in $outdir/$prefix.res";
system "$lefse/plot_res.py $outdir/$prefix.res --dpi 300 $outdir/$prefix.png";
#########################get the species name
`cd $outdir && $lefse/plot_features.py -f diff --archive zip --dpi 300 $prefix.in $prefix.res biomarkers.zip | grep \"Exporting\" | awk \'{print \$2}\'>$outdir/species_name.xls`;
open(NAME,"$outdir/species_name.xls");
my %hash;
while (<NAME>)
{
    chomp;
    my @array=split(/\./,$_);
    $hash{$array[$#array]}=1;
}
######################read the count and output species abudance
open(COUNT,"$input");
open(LESE,">$outdir/lefse_heatmap.xls");
my %name;
my $line=0;
while (<COUNT>)
{
    chomp;
    $line++;
    if ($line==$subject) {
        print LESE $_,"\n";
    }
    
    my @array=split(/\t/,$_);
    my @array2=split(/\|/,$array[0]);
    $array2[$#array2]=~s/ //g;
    $array2[$#array2]=~s/\./\_/g;
    $array2[$#array2]=~s/\:/\_/g;
    $array2[$#array2]=~s/\,/\_/g;
    $array2[$#array2]=~s/\;/\_/g;
    $array2[$#array2]=~s/\-/\_/g;
    $array2[$#array2]=~s/\[/\_/g;
    $array2[$#array2]=~s/\]/\_/g;
    $array2[$#array2]=~s/\)/\_/g;
    $array2[$#array2]=~s/\(/\_/g;
                    
    if (exists $hash{$array2[$#array2]})
    {
        print LESE $_,"\n";
    } 
}
my $norm="log";
`$metaphlan/utils/metaphlan_hclust_heatmap.py -c GnBu --top 100 --tax_lev a --minv 0.01 -s $norm --in $outdir/lefse_heatmap.xls  --out $outdir/abundance_all.heatmap.png`;
