#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use FindBin qw($Bin);
my($pep,$outdir,$result);
GetOptions(
    "i:s"=>\$pep,
    "o:s"=>\$outdir,
    "r:s"=>\$result,
           );

sub usage{
        print qq{
This script was used to annotated card.
notice:please put the ncbi++ in your enviroment.
usage:
perl $0 -p protein.fasta -i /xx/final.xls -o /xx/result.txt
-i          input the final result of the blast card.
-o          output the result.
-r	    output picture name.
        };
    exit;
}
if (!$pep||!$outdir||!$result)
{
    &usage();
}

open IN,"$pep" or die;
my %uniq=();
my %hash=();
<IN>;
while(<IN>){
	chomp;
	my @cut=split /\t/,$_;
	if(exists $uniq{$cut[5]}){
		if($uniq{$cut[5]} eq $_){next;}
		else{
			if(exists $hash{$cut[4]}){$hash{$cut[4]}++;}
			else{$hash{$cut[4]}=1;}
		}
	}
	else{
		if(exists $hash{$cut[4]}){$hash{$cut[4]}++;}
                else{$hash{$cut[4]}=1;}
		$uniq{$cut[5]}=$_;
	}
}
close IN;
my $i=1;
open OUT,">$outdir/statics.txt" or die;
print OUT "AROID\tNum\tpercent\n";
my $temp=0;
foreach my $keys(sort {$hash{$b} <=> $hash{$a} }keys %hash){
	if($i>=13){
		#$temp=$temp+$hash{$keys};
		#next;
		last
	}
	#print OUT "$keys\t$hash{$keys}\n";
	$temp=$temp+$hash{$keys};
	$i++;
}
#print OUT "other\t$temp\n";
$i=0;
my $max=0;
foreach my $keys(sort {$hash{$b} <=> $hash{$a} }keys %hash){
	if($i>=13){
		last;
	}
	if($i==1){$max=$hash{$keys}*2};
	my $percent=$hash{$keys}/$temp*100;
	print OUT "$keys\t$hash{$keys}\t";
	print OUT sprintf("%.2f", $percent)."%\n";
	$i++;
}
close OUT;

open CMD,">$outdir/cmd.r" or die;
print CMD "
library(RColorBrewer)
pdf(\"$outdir/$result.pdf\",height=6,width=10)
par(mfrow=c(1,2))
#layout(matrix(c(1,2),nr=1))
col=c(\"lightblue\",\"wheat\",\"darkgreen\",\"limegreen\",\"lightseagreen\",\"lightsteelblue\",\"rosybrown\",\"tomato\",\"lightpink\",\"deeppink\",\"gray\",\"gold\",\"slateblue\",\"mediumvioletred\",\"deepskyblue\",\"darkorange\",\"midnightblue\",\"forestgreen\",\"violet\",\"darkgoldenrod\")
a<-read.table(\"$outdir/statics.txt\",header=T,sep=\"\t\")
legend<-a\$AROID
labels<-a\$percent
y=a\$Num
pie(y,labels=labels,col=col,cex=0.6,edges = 300,radius = 1,border =\"white\",main=\"Functional Categories\")
#legend(\"top\",legend=legend,col=col,fill=col,box.lwd=0,cex=0.6,border =\"white\",ncol=2)

barplot(a\$Num,width=2.5,space =0,col =col,ylim=c(0,$max),main=\"Genes\",horiz=T,names.arg=a\$Num,las=1,cex.names=0.8)
legend(\"topright\",legend=legend,col=col,fill=col,box.lwd=0,cex=1,border =\"white\")
dev.off()

png(\"$outdir/$result.png\",height=800,width=1100,res=100)
#layout(matrix(c(1,2),nr=1))
par(mfrow=c(1,2))
pie(y,labels=labels,col=col,cex=1,edges = 300,radius = 1,border =\"white\",main=\"Functional Categories\")
barplot(a\$Num,width=2.3,space =0,col =col,ylim=c(0,$max),main=\"Genes\",horiz=T,names.arg=a\$Num,las=1,cex.names=0.8)
legend(\"topright\",legend=legend,col=col,fill=col,box.lwd=0,cex=1,border =\"white\")

dev.off()
\n";

`R --restore --no-save < $outdir/cmd.r`;
#system "rm $outdir/cmd.r";

close CMD;
