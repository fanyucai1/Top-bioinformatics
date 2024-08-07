#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;

my($pep,$outdir,$ARDB);
GetOptions(
    "p:s"=>\$pep,
    "o:s"=>\$outdir,
    "d:s"=>\$ARDB, 
           );

sub usage{
    print qq{
This script was used to annotated ARDB.
usage:
perl $0 -p protein.fasta -o $outdir -d /path/to/ARDB/
-p          the query protein fasta
-o          the output directory
-d          the path of ARDB database(/allwegene3/work/jianghao/software/ARDB/ardbAnno1.0/)
    };
    exit;
}
if (!$pep || !$outdir||!$ARDB)
{
    &usage();
}

system "mkdir -p $outdir/";

system "rm -rf $ARDB/test.pfasta && ln -s $pep $ARDB/test.pfasta";
system "cd $ARDB/ && perl ardbAnno.pl";
system "mv $ARDB/test.anno $outdir/";
system "mv $ARDB/output.xls $outdir/";

