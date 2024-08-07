#!/usr/bin/perl -w
#author hao.jiang,396041759@qq.com
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use FindBin qw($Bin);


my($pep,$outdir,$card,$type,$threads,$evalue);
GetOptions(
    "p:s"=>\$pep,
    "o:s"=>\$outdir,
    "d:s"=>\$card,
    "type:s"=>\$type,
    "t:i"=>\$threads,
    "e:s"=>\$evalue,
           );

$threads||=10;
$card||="/allwegene3/work/jianghao/software/card/database/protein";
$evalue||="1e-10";

sub usage{
	print qq{
This script was used to annotated card.
notice:please put the ncbi++ in your enviroment.
usage:
perl $0 -p protein.fasta -o /path/xx/xx -d /xx/xx/prot
-p          the query protein fasta
-o          the output directory
-d          the database of card.
	    /allwegene1/work/jianghao/software/card/database/protein.(prot)
	    /allwegene1/work/jianghao/software/card/database/nucleotide.(nucl)
            default prot.
-type	    the file type you input.(prot or nucl?)    
-t	    the threads num set.default 10.
-e	    the evalue of blast,default 1e-10.
	};
    exit;
}
if (!$pep || !$outdir || !$type)
{
    &usage();
}

my $out_name=(split /\//,$pep)[-1];
system "mkdir -p $outdir/";
my $blast="";
my $card_type=(split /\//,$card)[-1];
if($type eq 'prot'){
	if($card=~/nucl/){$blast="tblastn";}
	else{$blast="blastp";}
}
elsif($type eq 'nucl'){
	if($card=~/nucl/){$blast="blastn";}
	else{$blast="blastx";}
}
else{
	print "please input the correct type of your input file.\n";
	&usage(); 
}
print "begining blast,please wait .......\n";
system "$blast -query $pep -db $card -num_threads $threads -max_target_seqs 1 -evalue $evalue -outfmt \"6 qseqid sseqid salltitles qlen qstart qend slen sstart send evalue bitscore pident\" -out $outdir/$out_name\_card_result.xls";
print "blast is over,result at $outdir ,the card_result files\n\n";
print "clear up the final result now,please wait.......\n";

my %hash=();
open IN,"$Bin/aro.txt" or die "please check out the aro.txt\n";
while(<IN>){
	chomp;
	$_=~s/\r+//g;
	my $cut=(split /\t/,$_)[0];
	$hash{$cut}=$_;
}
close IN;


my %category=();
open IN,"$Bin/aro_categories_index.txt" or die "please check out the aro_categories_index.txt\n";
while(<IN>){
	chomp;
	$_=~s/\r+//g;
	my @cut=split /\t/,$_;
	my $flag=(split /\s+/,$cut[2])[-1];
	if($flag=~/gene/){
		#next;
		$category{$cut[0]}=$cut[2];
		#print "$cut[0]\t$category{$cut[0]}\n";
	}
	else{
		#$category{$cut[0]}=$cut[2];
		#print "$cut[0]\t$category{$cut[0]}\n";
		next;
	}
}
close IN;

my %static_category=();


open IN,"$outdir/$out_name\_card_result.xls" or die;
open OUT,">$outdir/$out_name\_final_result.xls" or die;
#print OUT "Resistance_Type\tDescription\tResistance_Profile\tTax\tAccession\tQuery_seq\tCategory\n";
print OUT "Resistance_Type\tDescription\tResistance_Profile\tTax\tAccession\tQuery_seq\n";
while(<IN>){
	chomp;
	my @cut=split /\t/,$_;
	my $length=$cut[5]-$cut[4]+1;
	next if($cut[-1]<60 or $length<25);
	my $seqid=$cut[0];
	my ($gi,$aro,$resistance_type)=(split /\|/,$cut[1])[1,-2,-1];
	my $tax||="none";
	$tax=(split /\]/,(split /\[/,$cut[2])[1])[0];
	$category{$gi}||="other";
	if(exists $hash{$aro}){
		my ($accession,$resistance_profile,$description)=(split /\t/,$hash{$aro})[0,1,2];
		#print OUT "$resistance_type\t$description\t$resistance_profile\t$tax\t$accession\t$seqid\t$category{$gi}\n";
		print OUT "$resistance_type\t$description\t$resistance_profile\t$tax\t$accession\t$seqid\n";

		if(exists $static_category{$gi}){
			$static_category{$category{$gi}}=1;
		}
		else{
			$static_category{$category{$gi}}++;
		}

	}
	else{die "err!\t not have this accection\n";}
}
close IN;
close OUT;

=head
open OUT,">$outdir/$out_name\_statics_category.txt" or die;
print OUT "Category\tNum\n";
foreach my $keys(sort { $static_category{$b} <=> $static_category{$a} }keys %static_category){
	print OUT "$keys\t$static_category{$keys}\n";
}
close OUT;

open CMD,">$outdir/cmd.r" or die;
print CMD "
	library(ggplot2)
	data<-read.table(\"$outdir/$out_name\_statics_category.txt\",header=T)
	png(\"distribution.png\",height=600,width=700,res=150)
	ggplot(data,aes(x=Category,y=Num))+geom_bar(stat=\"identity\",colour=Category,fill=Category)+xlab(\"Type of gene\")+ylab(\"NUM of every type\")+theme_bw()+labs(title=\"The distribute of all Type genes\")+theme(axis.text.x  = element_text(angle=45, vjust=0.5))
	dev.off()
\n";

close CMD;
`R --restore --no-save < $outdir/cmd.r`;
system "rm $outdir/cmd.r";
=cut
print "over of all! result at $outdir final_reslt files.\n";

system "perl $Bin/statics_ARO.pl -i $outdir/$out_name\_final_result.xls -o $outdir -r $out_name";
