#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;
use Cwd;
my (@bam,$outdir,@prefix,$chrnum,$genomeSize,$bed,$queue,$ass_maxproc);
my $R="Rscript";
my $samtools="/allwegene3/soft/public/samtools/samtools-v1.3.1/bin/samtools";
my $picard="/allwegene3/work/fanyucai/software/picard/picard-2.6.0/picard.jar";
my $bedtools="/allwegene3/soft/public/bedtools2_v2.25/bin/bedtools";
my $inner_distance="/allwegene3/soft/public/python/Python-v2.7.13/bin/inner_distance.py";
my $python="/allwegene3/soft/public/python/Python-v2.7.13/bin";
my $geneBody_coverage="/allwegene3/soft/public/python/Python-v2.7.13/bin/geneBody_coverage.py";
my $RPKM_saturation="/allwegene3/pipeline/DGE/RNA_assessment/RPKM_saturation.py";
my $qsub="/allwegene3/work/jianghao/qsub_sge.pl";

my $pdfw||=10;
my $pdfh||=10;
my $pngw||=2000;
my $pngh||=2000;
my $window||=1000;
GetOptions(
    "bam:s{1,}"=>\@bam,
    "o:s"=>\$outdir,
    "p:s{1,}"=>\@prefix,
    "pdfw:s"=>\$pdfw,
    "pdfh:s"=>\$pdfh,
    "pngw:s"=>\$pngw,
    "pngh:s"=>\$pngh,
    "queue:s"=>\$queue,
    "ass_maxproc:i"=>\$ass_maxproc,
    "chrnum:s"=>\$chrnum,
    "genomeSize:s"=>\$genomeSize,
    "w:s"=>\$window,
    "bed:s"=>\$bed,
           );

$ass_maxproc||=6;
$queue||="big.q";

sub usage{
    print qq{
This script plot barplot with mapped/unmapped reads,insert length,chromosome coverage.
Attention:As the analysis of without_RNAseq,the bam file will not delet dumplicate.

usage:
perl $0 -bam sample1.bam sample2.bam -o /path/to/outdir -p sample1 sample2 -chrnum 10 -w 1000 -genomeSize genome.fa.fai
                    or
perl $0 -bam sample1.bam sample2.bam -o /path/to/outdir -p sample1 sample2 -bed
                    or
perl $0 -bam sample1.bam sample2.bam -o /path/to/outdir -p sample1 sample2 
options:
-bam            input file,you could input several files and split by space(force)
-genomeSize     input bed file contains chromosome size this file from samtools faidx ouput
-chrnum         the chromosome number plot in the picture
-bed            the bed file from transdecoder(As the analysis of without_RNAseq, if you set this parameter,the script will plot rand curve and saturation curve.)
-w              the silde window(default:1000)
-o              the out directory(force)
-p              the prefix of output files(force)
-pdfw           the width of pdf(default:10)
-pdfh           the height of pdf(default:10)
-pngw           the width of png(default:2000)
-pngh           the height of png(default:2000)
-ass_maxproc    the progress onece running.default 6 .
-queue	        the queue you choose set.default big.q .
Email:fanyucai1\@126.com
    };
    exit;
}
if (!@bam || !$outdir || !@prefix)
{
    &usage();
}
######plot mapping ratio
system "echo '#sampleID\tTotal\tMapped\tMapped_Ratio' >$outdir/mapped_ratio.xls";
my @type;
open(BAM,">$outdir/bamstas.sh");
open(INSERT,">$outdir/insert.sh");
for (my $i=0;$i<=$#bam;$i++)
{
	print BAM "$samtools flagstat $bam[$i] >$outdir/$prefix[$i]_bam_flagstat.txt\n";
}
&qsub("$outdir/bamstas.sh",$queue,$ass_maxproc);
#`perl $qsub $outdir/bamstas.sh`;
for (my $i=0;$i<=$#bam;$i++)
{
    my ($total,$mapped,$total1,$mapped1,$ratio);
    open(FLAG,"$outdir/$prefix[$i]_bam_flagstat.txt");
    while(<FLAG>)
    {
        chomp;
        my @array=split;
        #pair_end
        if($_=~ 'paired in sequencing')
        {
            $total=$array[0];
            chomp($total);
        }
        if($_=~ 'properly paired')
        {
            $mapped=$array[0];
            chomp($mapped);
        }
        #single_read
        if($_=~"QC-passed reads")
        {
            $total1=$array[0];
            chomp($total1);
        }
        if($_=~"0 mapped")
        {
            $mapped1=$array[0];
            chomp($mapped1);
        }
    }
    if($total==0)
    {
        $type[$i]="s";
        $total=$total1;
        $mapped=$mapped1;
    }
    else
    {
        $type[$i]="p";
    }
    $ratio=$mapped/$total;
    close FLAG;
    system "echo '$prefix[$i]\t$total\t$mapped\t$ratio' >>$outdir/mapped_ratio.xls";
    if($type[$i] ne "s")
    {
        print INSERT "java -jar $picard CollectInsertSizeMetrics I=$bam[$i]  H=$outdir/$prefix[$i]\_insert_size_histogram.pdf O=$outdir/$prefix[$i]\_insert_size_metrics.txt\n";
    }
}
if($type[$#type] ne "s")
{
	&qsub("$outdir/insert.sh",$queue,$ass_maxproc);
	#`perl $qsub $outdir/insert.sh`;
}

for (my $i=0;$i<=$#bam;$i++)
{
	if($type[$i] ne "s")
    {
        system "java -jar $picard CollectInsertSizeMetrics I=$bam[$i]  H=$outdir/$prefix[$i]\_insert_size_histogram.pdf O=$outdir/$prefix[$i]\_insert_size_metrics.txt";
        open(IN,"$outdir/$prefix[$i]\_insert_size_metrics.txt");
        my $num=0;
        TT:while (<IN>)
        {
            chomp;
            if ($_ =~"All_Reads.fr_count")
            {
                ++$num;
                system "echo $_ >$outdir/$prefix[$i]\_insert_size.txt";
                next TT;
            }
            if ($num==1)
            {
                system "echo $_ >>$outdir/$prefix[$i]\_insert_size.txt";
            }  
        }
        close IN;
        system "rm -rf $outdir/$prefix[$i]\_insert_size_metrics.txt *insert_size_histogram.pdf";
    }
}
######################################plot insert length
    system "echo '#!$R'>$outdir/plot.insert.R";
    for(my $i=0;$i<=$#bam;$i++)
    {
        if($type[$i] ne "s")
        {
            system "echo 'a<-read.table(\"$outdir/$prefix[$i]\_insert_size.txt\",header=T)'>>$outdir/plot.insert.R";
            system "echo 'x<-a\$insert_size'>>$outdir/plot.insert.R";
            system "echo 'y<-a\$All_Reads.fr_count'>>$outdir/plot.insert.R";
            system "echo 'png(filename=\"$outdir/$prefix[$i].insert_length.png\",res=300,width=$pngw,height=$pngh)'>>$outdir/plot.insert.R";
            system "echo 'plot(spline(x,y), pch=20,xlab=\"Insert size\", ylab=\"reads number\", lwd=2,type=\"l\", main=paste(\"Insert size distribution\"),col=2)'>>$outdir/plot.insert.R";
            system "echo 'dev.off()'>>$outdir/plot.insert.R";
            system "echo 'pdf(file=\"$outdir/$prefix[$i].insert_length.pdf\",width=$pdfw,height=$pdfh)'>>$outdir/plot.insert.R";
            system "echo 'plot(spline(x,y), pch=20,xlab=\"Insert size\", ylab=\"reads number\", lwd=2,type=\"l\", main=paste(\"Insert size distribution\"),col=2)'>>$outdir/plot.insert.R";
            system "echo 'dev.off()'>>$outdir/plot.insert.R";
        }
    }
system "$R $outdir/plot.insert.R && rm $outdir/plot.insert.R";

######################################plot sequencing coverage based on bam files
if($window && $genomeSize)
{
    my $x_title||= "Chromsome position";
    my $y_title||= "Read deinsity(log(2))";
    my $title||= "Genomewide distribution of read coverage";
    system "echo '#!$R'>$outdir/plot_per_chrom_cov.R";
    open(IN,"$outdir/$genomeSize");
    open(OUT,">$outdir/samtools.new.fai");
    my (%hashl,%hash);
    my $i=0;
    while (<IN>)
    {
        chomp;
	my @array=split;
	$hashl{$array[0]}=$array[1];
	$hash{$array[0]}=$_;
    }
    foreach my $key(sort {$hashl{$b} <=> $hashl{$a}} keys %hashl)
    {
        $i++;
	if ($i<=$chrnum)
	{
	    print OUT $hash{$key},"\n";
	}
    }
    system "$bedtools makewindows -g $outdir/samtools.new.fai -w $window >$outdir/ref.$window\_chr.bed";
    for(my $i=0;$i<=$#bam;$i++)
    {
        system "$samtools bedcov $outdir/ref.$window\_chr.bed $bam[$i] >$outdir/$prefix[$i].$window.cov";
        system "echo 'x<-read.table(\"$outdir/$prefix[$i].$window.cov\")'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'chr<-x[,1]'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'pos<-x[,3]'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'depth<-(x[,4]+1)/$window'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'depth<-log2(depth)'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'df  <- data.frame(chr, pos, depth)'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'require(ggplot2)'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'pdf(file=\"$outdir/$prefix[$i]\_cov.pdf\",width=40,height=30)'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'p <- ggplot(data = df, aes(x=pos, y=depth),binwidth = 0.1) + geom_area(aes(fill=chr))'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'p=p+xlab(\"$x_title\")+ylab(\"$y_title\")+ggtitle(\"$title\")'>>$outdir/plot_per_chrom_cov.R";
	system "echo 'p + facet_wrap(~ chr, ncol=1)'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'dev.off()'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'png(filename=\"$outdir/$prefix[$i]\_cov.png\",width=6000,res=300,height=5000)'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'p <- ggplot(data = df, aes(x=pos, y=depth),binwidth = 0.1) + geom_area(aes(fill=chr))'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'p=p+xlab(\"$x_title\")+ylab(\"$y_title\")+ggtitle(\"$title\")'>>$outdir/plot_per_chrom_cov.R";
	system "echo 'p + facet_wrap(~ chr, ncol=1)'>>$outdir/plot_per_chrom_cov.R";
        system "echo 'dev.off()'>>$outdir/plot_per_chrom_cov.R";
    }
    system "$R $outdir/plot_per_chrom_cov.R";
}

if($bed)
{
    for(my $i=0;$i<=$#bam;$i++)
    {
        system "$python $RPKM_saturation -r $bed -i $outdir/$bam[$i] -o $outdir/$prefix[$i]\.saturation_curve";
        system "$python $geneBody_coverage -r $bed -i $outdir/$bam[$i] -o $outdir/$prefix[$i]\.rand";
    }
}


sub qsub()
{
    my ($shfile, $queue, $ass_maxproc) = @_ ;
    $queue||="big.q";
    $ass_maxproc||=5;
    my $cmd = "perl $qsub --maxproc $ass_maxproc --queue $queue --resource vf=15G --reqsub $shfile --independent" ;
    my $flag=system($cmd);
    if($flag !=0)
    {
                die "qsub [$shfile] die with error : $cmd \n";
        exit;
        }
}
