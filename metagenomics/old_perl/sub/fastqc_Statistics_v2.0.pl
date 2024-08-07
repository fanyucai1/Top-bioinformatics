#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use FindBin qw($Bin);
my (@pe1,@pe2,$outdir,@sampleID,$prefix);
my $fastq_qc_stat="$Bin/fastq_qc_stat";
my $qual="/allwegene1/work/fanyucai/script/GCqual_Solexa_check_svg_final.pl";
my $cont="/allwegene1/work/fanyucai/script/GCcont_Solexa_check_svg_final_v1.pl";
my $env="export LD_LIBRARY_PATH=/allwegene1/work/fanyucai/software/R/R-v3.2.4/lib64/R/lib/:/allwegene1/work/fanyucai/software/lib:/allwegene1/work/fanyucai/software/gsl/gsl-v1.13/lib:\$LD_LIBRARY_PATH";
my $qsub="/allwegene1/work/fanyucai/software/qsub/qsub_sge.pl";
GetOptions(
     "a:s{1,}"=>\@pe1,       
     "b:s{1,}"=>\@pe2,
     "o:s"=>\$outdir,
     "id:s{1,}"=>\@sampleID,
     "p:s"=>\$prefix
           );
sub usage{
    print qq{
This script could satistics the PE_fastq file.
usage:
perl $0 -a sample1_1.fq sample2_1.fq -b sample1_2.fq sample2_2.fq -id sample1 sample2 -o /path/to/diretory -p prefix
options:
-a        input fastq file,several files split by space(force)
-b        input fastq file,several files split by space(force)
-o        the output directory(force)
-id       sampleID,several IDs split by space(force)
-p        the prefix of output
Email:fanyucai1\@126.com
2016.11.7
vesion:1.1
    };
    exit;
}
if (!@pe1 || !$outdir||!@sampleID || !@pe2) {
    &usage();
}
system "mkdir -p $outdir";
my @left=@pe1;
my @id=@sampleID;
if ($prefix) {
    open(OUT,">$outdir/$prefix.statistics_fq.xls");
}
else
{
   open(OUT,">$outdir/statistics_fq.xls");
}

print OUT "Samples\tRead_Number\tBase_Number\tGC_Content(%)\t%>Q20\t%>Q30\n";
my @right=@pe2;
open(FA,">$outdir/fastqc.sh");
open(FAA,">$outdir/plot.sh");
for(my $k=0;$k<=$#left;$k++)
{
        if(! -e "$outdir/$id[$k].quality" || !-e "$outdir/$id[$k].acgtn")
        {
            print FA "$env && $fastq_qc_stat -a $left[$k] -b $right[$k] -f $outdir/$id[$k] -q 100\n";
        }
        if(!-e "$outdir/$id[$k].quality.png")
        {
            print FAA "perl $qual -qu $outdir/$id[$k].quality -od $outdir/\n";
        }
        if(!-e "$outdir/$id[$k].acgtn.png")
       	{
            print FAA "perl $cont -gc $outdir/$id[$k].acgtn -od $outdir/\n";
        }
} 
`perl $qsub $outdir/fastqc.sh`;
`perl $qsub $outdir/plot.sh`;
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
print "clean data statistics run done.\n";
