#!/usr/bin/perl -w
use strict;
use warnings;
use Cwd;
use Getopt::Long;
use FindBin qw($Bin);

my(@input,$outdir,@id);
GetOptions(
       "i:s{1,}"=>\@input,
       "o:s"=>\$outdir,
       "id:s{1,}"=>\@id,
           );

sub usage{
    print qq {
This script will parse diamond result from blast2lca output.
usage:
perl $0 -i sample1.diamond.out  sample2.diamond.out -id sample1 sample2 -o /path/to/directory -xls sample1_total.xls sample2_total.xls
options:
-i                  the blast2lca output (many samples files could input )
-id                 the sample ID
-p                  the prefix of output
-o                  output directory
-xls                the ouput of diamond.pl(xls)
Email:fanyucai1\@126.com
2016.11.30
    };
    exit;
}