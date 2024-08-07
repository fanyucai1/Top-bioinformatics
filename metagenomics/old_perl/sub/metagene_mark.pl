#!/usr/bin/env perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use FindBin qw($Bin);
use File::Basename;

my($outdir,$contig,@pe1,@pe2,@prefix,$queue);
my $metagenemark="/allwegene3/soft/public/meta_geneMarker/MetaGeneMark_linux_64/mgm/";
#
my $prodigal="/allwegene3/work/fanyucai/software/Prodigal/prodigal.linux";
my $nt_from_gff="$Bin/nt_from_gff.pl";
my $aa_from_gff="$Bin/aa_from_gff.pl";
my $cdhit="/allwegene3/work/fanyucai/software/cdhit/cdhit-master";
my $qsub="/allwegene3/work/jianghao/qsub_sge.pl";
my $bowtie="/allwegene3/soft/public/bowtie/bowtie-1.1.2";
my $bowtie2="/allwegene3/soft/public/bowtie/bowtie2-2.2.6";
my $samtools="/allwegene3/soft/public/samtools/samtools-v1.3.1/bin/samtools";
my $bam_script="$Bin/bam_statistics.pl";
my $python="/allwegene3/soft/public/python/Python-v2.7.13/bin/python";
my $quast="/allwegene3/soft/public/quast/quast-4.4/quast.py";
my $sam2count="$Bin/sam2counts.py";
$queue||="big.q";
my $ass_maxproc||=5;

GetOptions(
	"contig:s"=>\$contig,
	"queue:s"=>\$queue,
	"pe1:s{1,}"=>\@pe1,
	"pe2:s{1,}"=>\@pe2,
	"p:s{1,}"=>\@prefix,
	"o:s"=>\$outdir,
);
sub usage{
	print qq{
usage:
perl $0 -contig contig.fa -o /path/to/outdir/
			or
perl $0 -contig contig.fa -o /path/to/outdir/ -pe1 sample1.1.fq sample2.1.fq -pe2 sample1.2.fq sample2.2.fq -p sample1 sample2 -queue big.q

2018,03,23
version2.2
};
exit;		
}
if(!$outdir||!$contig)
{
	&usage();
}
###################################step1:build contig index and predict gene
open(GENE,">$outdir/gene.1.sh");
system "mkdir -p $outdir/gene";
chomp(my $who=`whoami`);
#print GENE "cp $metagenemark/gm_key_64 /home/$who/.gm_key && $metagenemark/gmhmmp -a -d -f G -m $metagenemark/MetaGeneMark_v1.mod -o $outdir/gene.gff $contig\n";
print GENE "$prodigal -a $outdir/pro.fasta -d $outdir/nucl.fasta -f gff -i $contig -o $outdir/gene.gff -p meta\n";

my $dir=dirname $contig;
print GENE "cd $dir && $bowtie2/bowtie2-build $contig $dir/final.contigs.fa\n";
print GENE "mkdir -p $dir/quast && $python $quast $contig -o $dir/quast --no-plots --no-html\n";
#`perl $qsub $outdir/gene.1.sh`;

&qsub("$outdir/gene.1.sh",$queue,$ass_maxproc);

###################################step2:extract nucl and pro seqence
open(GENE2,">$outdir/gene.2.sh");
#
print GENE2 "$cdhit/cd-hit-est -i $outdir/nucl.fasta -o $outdir/non-redundant-nucl.fasta -c 0.95 -M 10000 -T 80 && $bowtie/bowtie-build $outdir/non-redundant-nucl.fasta $outdir/gene_bowtie\n";
#print $bowtie2/bowtie2-build $outdir/non-redundant-nucl.fasta $outdir/gene_bowtie\n";

#print GENE2 "perl $nt_from_gff $outdir/gene.gff >$outdir/nucl.fasta && $cdhit/cd-hit-est -i $outdir/nucl.fasta -o $outdir/non-redundant-nucl.fasta -c 0.95 -M 10000 -T 10 -aS 0.9 && $bowtie/bowtie-build $outdir/non-redundant-nucl.fasta $outdir/gene_bowtie\n";
#print GENE2 "perl $aa_from_gff $outdir/gene.gff >$outdir/pro.fasta\n";

#`perl $qsub $outdir/gene.2.sh`;
&qsub("$outdir/gene.2.sh",$queue,$ass_maxproc);
my ($bam,$sam);
if($#pe1>=0)
{
	open(GENE3,">$outdir/gene.3.sh");
	for(my $k=0;$k<=$#pe1;$k++)
	{
		############mapping reads to contigs
		print GENE3 "$bowtie2/bowtie2 -x $dir/final.contigs.fa -p 25 -1 $pe1[$k] -2 $pe2[$k] -S $dir/$prefix[$k].sam && $samtools view -Sb $dir/$prefix[$k].sam -o $dir/$prefix[$k].bam && $samtools sort $dir/$prefix[$k].bam -o $dir/$prefix[$k]_sort.bam && ";
		print GENE3 "rm $dir/$prefix[$k].sam  $dir/$prefix[$k].bam\n";
		############mapping reads to genes
		print GENE3 "$bowtie/bowtie -S -n 2 -l 35 -e 200 --best -p 25 --chunkmbs 1026 -X 600 --tryhard $outdir/gene_bowtie -1 $pe1[$k] -2 $pe2[$k] $outdir/$prefix[$k].sam\n";
		#print GENE3 "$bowtie2/bowtie2 -N 1 -L 31 -p 15 -x $outdir/gene_bowtie -1 pe1[$k] -2 $pe2[$k] -S $outdir/$prefix[$k].sam\n";
		
		$bam.="$dir/$prefix[$k]_sort.bam ";
		$sam.="$outdir/$prefix[$k].sam ";
	}
#`perl $qsub $outdir/gene.3.sh`;
&qsub("$outdir/gene.3.sh",$queue,$ass_maxproc);
}
###########################get mapping ratio
if($#pe1>=0)
{
	`mkdir -p $outdir/result/`;
	`perl $bam_script -bam $bam -p @prefix -o $dir/`;
}
#############################sam2count
if($#pe1>=0)
{
	open(TAXX,">$outdir/sam2count.sh");
	`mkdir -p $outdir/result/`;
	print TAXX "$python $sam2count -o $outdir/result/raw_count.txt $sam\n";
	#`perl $qsub $outdir/sam2count.sh`;
	&qsub("$outdir/sam2count.sh",$queue,$ass_maxproc);
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

