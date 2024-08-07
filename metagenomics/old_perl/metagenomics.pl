#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use FindBin qw($Bin);
use Config::IniFiles;

my ($config,$qc);
my $host||="F";
my $num||="0";
$qc||="false";
GetOptions(
    "i:s"=>\$config,
    "host:s"=>\$host,
    "qc:s"=>\$qc,
           );

sub usage{
    print qq (
This script will run the metapipeline.
usage:
perl $0 -i config.ini -host false
options:
-i                	the config file
-host          		whether filter host sequence:ture or false(default:false)
-qc             	if you input raw data,you should quality control:ture or false(default:false)							
    );
    exit;
}
if(!$config)
{
    &usage();
}
my %ini;
tie %ini, 'Config::IniFiles', ( -file => $config);
sub qsub()
{
	my ($shfile, $queue, $ass_maxproc) = @_ ;
    $queue||="big.q";
    $ass_maxproc||=10;
    my $cmd = "perl $ini{qsub}{qsub} --maxproc $ass_maxproc --queue $queue --resource vf=15G --reqsub $shfile --independent" ;
    my $flag=system($cmd);
    if($flag !=0)
    {
		die "qsub [$shfile] die with error : $cmd \n";
        exit;
	}
}
system "mkdir -p $ini{dir}{outdir}/shell";
#############################################################Raw2clean data
$num++;
system "mkdir -p $ini{dir}{outdir}/qc";
open(QC,">$ini{dir}{outdir}/shell/qc.$num.sh");
#print QC "source $Bin/bash_profile.txt\n";
if($qc =~/t/i)
{
    my($string1,$string2,$prefix);
    foreach my $key (keys %{$ini{sample}})
    {
        my @array=split(/\|/,$ini{'sample'}{$key});
        $string1.="$array[0] ";
        $string2.="$array[1] ";
        $prefix.="$key ";
    }
    print QC "perl $Bin/sub/quality_control.pl -pe1 $string1 -pe2 $string2 -o $ini{dir}{outdir}/qc -p $prefix -minL $ini{par}{min_read_length}\n";
}
else
{
    foreach my $key (keys %{$ini{sample}})
    {
        my @array=split(/\|/,$ini{'sample'}{$key});
        if($array[0]=~/gz$/)
        {
            print QC "ln -s $array[0] $ini{dir}{outdir}/qc/$key\_1.fq.gz && ln -s $array[1] $ini{dir}{outdir}/qc/$key\_2.fq.gz\n";
        }
        else
        {
            print QC "ln -s $array[0] $ini{dir}{outdir}/qc/$key\_1.fq && ln -s $array[1] $ini{dir}{outdir}/qc/$key\_2.fq\n";
        }
    }
}
`sh $ini{dir}{outdir}/shell/qc.$num.sh`;
#
#
####################################################################filter_host
$num++;
system "mkdir -p $ini{dir}{outdir}/clean_data";
open(FILTER,">$ini{dir}{outdir}/shell/clean.$num.sh");
#print FILTER "source $Bin/bash_profile.txt\n";

my ($pe1,$pe2,$name,$class,$subclass);
$class||="";
$subclass||="";
if($host=~/T/i)
{
    my($string1,$string2,$prefix);
    foreach my $key (keys %{$ini{sample}})
    {
        $name.=" $key";
	if ($ini{par}{sample_num}>=1)#prepare parameter of diamond
	{
	    $class.="$ini{class}{$key} ";
	}
	if ($ini{par}{subclass}=~/t/i)
	{
	    $subclass.="$ini{subclass}{$key} ";
	}
        if(-e "$ini{dir}{outdir}/qc/$key\_1.fq")
        {
            $string1.="$ini{dir}{outdir}/qc/$key\_1.fq ";
            $string2.="$ini{dir}{outdir}/qc/$key\_2.fq ";
        }
        else
        {
            $string1.="$ini{dir}{outdir}/qc/$key\_1.fq.gz ";
            $string2.="$ini{dir}{outdir}/qc/$key\_2.fq.gz ";
        }
        $pe1.="$ini{dir}{outdir}/clean_data/$key\.1.fq ";
        $pe2.="$ini{dir}{outdir}/clean_data/$key\.2.fq ";
    }
    print FILTER "perl $Bin/sub/filter_host.pl -host $ini{host}{index} -pe1 $string1 -pe2 $string2 -o $ini{dir}{outdir}/clean_data -p $name\n";
}
else
{
    foreach my $key (keys %{$ini{sample}})
    {
        $name.="$key ";
	if ($ini{par}{sample_num}>=2)#prepare parameter of diamond
	{
	    $class.="$ini{class}{$key} ";
	}
	if ($ini{par}{subclass}=~/t/i)
	{
	    $subclass.="$ini{subclass}{$key} ";
	}
        if(-e "$ini{dir}{outdir}/qc/$key\_1.fq")
        {
            print FILTER "ln -s $ini{dir}{outdir}/qc/$key\_1.fq $ini{dir}{outdir}/clean_data/$key.1.fq\n";
            print FILTER "ln -s $ini{dir}{outdir}/qc/$key\_2.fq $ini{dir}{outdir}/clean_data/$key.2.fq\n";
        }
        else
        {
            print "please input fastq file suffix is fq\n\n";
            exit;
        }
        $pe1.="$ini{dir}{outdir}/clean_data/$key.1.fq ";
        $pe2.="$ini{dir}{outdir}/clean_data/$key.2.fq ";
    }
}
#`sh $ini{dir}{outdir}/shell/clean.$num.sh`;
#
#
#############################################################run the diamond,kraken and metaphlan
$num++;
system "mkdir -p $ini{dir}{outdir}/diamond";
#system "mkdir -p $ini{dir}{outdir}/kraken";
#system "mkdir -p $ini{dir}{outdir}/metaphlan";
open(TAX,">$ini{dir}{outdir}/shell/Taxonomy.$num.sh");
#print TAX "$Bin/bash_profile.txt\n";

if ($ini{par}{sample_num}>=2 && $ini{par}{subclass}=~/t/i)
{
    print TAX "nohup perl $Bin/sub/diamond_v2.0.pl -pe1 $pe1 -pe2 $pe2 -o $ini{dir}{outdir}/diamond/ -p $name -class $class -subclass $subclass &\n";
}
elsif($ini{par}{sample_num}>=2 && $subclass eq "")
{
    print TAX "nohup perl $Bin/sub/diamond_v2.0.pl -pe1 $pe1 -pe2 $pe2 -o $ini{dir}{outdir}/diamond/ -p $name -class $class &\n";
}
else
{
    print TAX "nohup perl $Bin/sub/diamond_v2.0.pl -pe1 $pe1 -pe2 $pe2 -o $ini{dir}{outdir}/diamond/ -p $name &\n";
}
#print TAX "nohup perl $Bin/sub/kraken.pl  -pe1 $pe1 -pe2 $pe2 -p $name -o  $ini{dir}{outdir}/kraken &\n";
#print TAX "nohup perl $Bin/sub/metaphlan.pl -pe1 $pe1 -pe2 $pe2 -p $name -o $ini{dir}{outdir}/metaphlan &\n";
#`sh $ini{dir}{outdir}/shell/Taxonomy.$num.sh`;
#
#
#################################################################Assembly use megahit
$num++;
open(ASSEMBLY,">$ini{dir}{outdir}/shell/assembly.$num.sh");
#print ASSEMBLY "source $Bin/bash_profile.txt\n";

system "mkdir -p $ini{dir}{outdir}/assembly/";
print ASSEMBLY "perl $Bin/sub/megahit.pl -pe1 $pe1 -pe2 $pe2 -t $ini{par}{assembly_thread} -l $ini{par}{min_contig_length} -p $name -o $ini{dir}{outdir}/assembly/\n";
print ASSEMBLY "ln -s $ini{dir}{outdir}/assembly/megahit/final.contigs.fa $ini{dir}{outdir}/assembly/contig.fasta\n";
#`sh $ini{dir}{outdir}/shell/assembly.$num.sh`;
#
##################################################################predict gene and mapping statistics
$num++;
open(GENE,">$ini{dir}{outdir}/shell/gene.$num.sh");
#print GENE "source $Bin/bash_profile.txt\n";

system "mkdir -p $ini{dir}{outdir}/gene";
print GENE "perl $Bin/sub/metagene_mark.pl -o $ini{dir}{outdir}/gene/ -contig $ini{dir}{outdir}/assembly/contig.fasta -p $name -pe1 $pe1 -pe2 $pe2";
#`sh $ini{dir}{outdir}/shell/gene.$num.sh`;
#
##################################################################normalize
$num++;
system "mkdir -p $ini{dir}{outdir}/gene/result/";
open(NOR,">$ini{dir}{outdir}/shell/normalize.$num.sh");
#print NOR "source $Bin/bash_profile.txt\n";

print NOR "perl $Bin/sub/normalize.pl -pe1 $pe1 -pe2 $pe2 -id $name -count $ini{dir}{outdir}/gene/result/raw_count.txt -o $ini{dir}{outdir}/gene/result/ -fa $ini{dir}{outdir}/gene/nucl.fasta\n";
#`sh $ini{dir}{outdir}/shell/normalize.$num.sh`;
#
#
##################################################################ARDB ,CAZyme annotation
$num++;
open(SPEC,">$ini{dir}{outdir}/shell/ardb_CAZYme.$num.sh");
#print SPEC "source $Bin/bash_profile.txt\n";

#system "mkdir -p $ini{dir}{outdir}/ardb";
system "mkdir -p $ini{dir}{outdir}/card";
system "mkdir -p $ini{dir}{outdir}/CAZyme";
#print SPEC "nohup perl $Bin/sub/ARDB.pl -p $ini{dir}{outdir}/gene/non-redundant-nucl.fasta -o $ini{dir}{outdir}/ardb -d $Bin/ardbAnno1.0/&\n";
print SPEC "nohup perl $Bin/sub/blast_card.pl -p $ini{dir}{outdir}/gene/non-redundant-nucl.fasta -o $ini{dir}{outdir}/card -type nucl -t 10 -e 1e-10 -d /allwegene3/work/jianghao/software/card/database/nucleotide &\n";
print SPEC "nohup perl $Bin/sub/CAZyme.pl -nucl $ini{dir}{outdir}/gene/non-redundant-nucl.fasta  -prot  $ini{dir}{outdir}/gene/pro.fasta -o $ini{dir}{outdir}/CAZyme/&\n";
#&qsub("$ini{dir}{outdir}/shell/ardb_CAZYme.$num.sh");
#`sh $ini{dir}{outdir}/shell/ardb_CAZYme.$num.sh`; 
#
#
##################################################################DGE analysis
if($ini{par}{DESeq2}=~/t/i)
{
    $num++;
    open(DGE,">$ini{dir}{outdir}/shell/DGE.$num.sh");
    #print DGE "source $Bin/bash_profile.txt\n";

    system "mkdir -p $ini{dir}{outdir}/DGE/";
    foreach my $key(keys %{$ini{compare}})
    {
        system "mkdir -p $ini{dir}{outdir}/DGE/$key";
        open(GROUP,">$ini{dir}{outdir}/DGE/group.$key.txt");
        my @array=split(/\,/,$ini{compare}{$key});
        my @array1=split(/\,/,$ini{group}{$array[0]});
        my @array2=split(/\,/,$ini{group}{$array[1]});
        for(my $i=0;$i<=$#array1;$i++)
        {
            print GROUP "$array[0]\t$array1[$i]\n";
        }
        for(my $j=0;$j<=$#array2;$j++)
        {
            print GROUP "$array[1]\t$array2[$j]\n";
        }
        close GROUP;
        #DESeq2
        print DGE "sed -e 's/\\.sam//g' $ini{dir}{outdir}/gene/result/normalize_count.xls >$ini{dir}{outdir}/gene/result/normalize_count.txt\n";
        print DGE "sed -e 's/\\.sam//g' $ini{dir}{outdir}/gene/result/raw_count.txt >$ini{dir}{outdir}/gene/result/raw_count.xls\n";
        print DGE "mv $ini{dir}{outdir}/gene/result/raw_count.xls $ini{dir}{outdir}/gene/result/raw_count.txt\n";
        print DGE "perl $Bin/sub/DGE.pl -g $ini{dir}{outdir}/DGE/group.$key.txt -o $ini{dir}{outdir}/DGE/$key/ -r $ini{dir}{outdir}/gene/result/raw_count.txt -n $ini{dir}{outdir}/gene/result/normalize_count.txt -F $ini{par}{fdr} -f $ini{par}{foldchange} -num $ini{par}{sample_num}\n";
    }
    #`sh $ini{dir}{outdir}/shell/DGE.$num.sh`;
}
###################################################################regular annotation
#
#
#gai 
$num++;
#my $par_anno="--GO ";
system "mkdir -p $ini{dir}{outdir}/regular_annotation/";
#open(CON,">$ini{dir}{outdir}/regular_annotation/anno.cfg");
system "cp /allwegene3/work/fanyucai/metagenomics/anno.cfg $ini{dir}{outdir}/regular_annotation/anno.cfg";
system "echo \"[query]\nmRNA=$ini{dir}{outdir}/gene/non-redundant-nucl.fasta\" >>$ini{dir}{outdir}/regular_annotation/anno.cfg";

=head
print CON "[query]\nmRNA=$ini{dir}{outdir}/gene/non-redundant-nucl.fasta\n";
print CON "[database]\n";
if(exists $ini{database}{nr}){print CON "nr=$ini{database}{nr}\n"; $par_anno.=" --nr ";}
if(exists $ini{database}{Swissprot}){print CON "Swissprot=$ini{database}{Swissprot}\n"; $par_anno.=" --swissprot ";}
if(exists $ini{database}{Kegg}){print CON "Kegg=$ini{database}{Kegg}\n";$par_anno.=" --kegg "};
if(exists $ini{database}{Pfam}){print CON "Pfam=$ini{database}{Pfam}\n";$par_anno.=" --pfam "};
if(exists $ini{database}{Cog}){print CON "Cog=$ini{database}{Cog}\n";$par_anno.=" --cog "};
if(exists $ini{database}{eggNOG}){print CON "eggNOG=$ini{database}{eggNOG}\n";$par_anno.=" --eggNOG "};
if(exists $ini{queue}{queue}){print CON "[queue]\nqueue=all.q\n";}
print CON "[par]\nblast_cpu=$ini{par}{blast_cpu}\nhmmscan_cpu=$ini{par}{hmmscan_cpu}\nblast_e=$ini{par}{blast_e}\nblast_cut=$ini{par}{blast_cut}\n$ini{par}{blast_fast}\n";
=cut
open(REG,">$ini{dir}{outdir}/shell/anno.$num.sh");
#print REG "source $Bin/bash_profile.txt\n";

print REG "perl $ini{script}{anno} -all yes -cfg $ini{dir}{outdir}/regular_annotation/anno.cfg -od $ini{dir}{outdir}/regular_annotation/\n";
#`nohup sh $ini{dir}{outdir}/shell/anno.$num.sh &`;
#
############################################################copy result to backup ,get xml file and html report
$num++;
system "mkdir -p $ini{dir}{outdir}/html ";
open(CP,">$ini{dir}{outdir}/shell/html.$num.sh");
#print CP "source $Bin/bash_profile.txt\n";

print CP "perl $Bin/sub/copy2result.pl -i $ini{dir}{outdir} -o $ini{dir}{outdir}/html -n $ini{par}{sample_num} && ";
print CP "cd $ini{dir}{outdir}/html && perl $Bin/sub/print_xml.pl -i $config -o $ini{dir}{outdir}/html/ && ";
print CP "cd $ini{dir}{outdir}/html && python $ini{script}{html} -i  output.xml -o  $ini{dir}{outdir}/html/";
#&qsub("$ini{dir}{outdir}/shell/html.$num.sh");
#
open EACH,">$ini{dir}{outdir}/shell/each.$num.sh" or die;
print EACH "perl /allwegene3/work/jianghao/meta/single_metagenomics/all_each_sample_anno.pl -gene_table $ini{dir}{outdir}/gene/result/normalize_count.txt -indir $ini{dir}{outdir}/regular_annotation/Result/ -outdir $ini{dir}{outdir}/regular_annotation/Result/\n";
close EACH;
