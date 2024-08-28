import sys,os
import re
import subprocess
import argparse

docker="meta:latest"
def run(contig,pe1,outdir,prefix,pe2=None):
    contig=os.path.abspath(contig)
    array=pe1.split(',')
    in_dir=os.path.dirname(os.path.abspath(array[0]))
    for i in range(1,len(array)):
        if in_dir!=os.path.abspath(array[i]):
            print("All sample reads must be in the same directory.")
    ref_name=contig.split('/')[-1]
    a=pe1.split("/")[-1]
    cmd="docker run -v %s:/ref/ -v %s:/raw_data/ -v %s:/outdir/ %s sh -c \'"%(os.path.dirname(contig),in_dir,os.path.abspath(outdir),docker)
    #########################################step1:Calculate contig coverage
    # https://github.com/voutcn/megahit/wiki/An-example-of-real-assembly#4-calculate-contig-coverage-and-extract-unassembled-reads
    if not os.path.exists(outdir):
        os.mkdir(outdir)
    if pe2 is not None:
        pe2=os.path.abspath(pe2)
        b=pe2.split("/")[-1]
        if in_dir!=os.path.dirname(pe2):
            print("read1 and reads2 must be in the same directory.")
            exit()
        cmd+="bbwrap.sh ref=/ref/%s in=/raw_data/%s in2=/raw_data/%s out=/outdir/%s.aln.sam.gz kfilter=22 subfilter=15 maxindel=80"%(contig.split('/')[-1],a,b,prefix)
    else:
        cmd += "bbwrap.sh ref=/ref/%s in=/raw_data/%s out=/outdir/%s.aln.sam.gz kfilter=22 subfilter=15 maxindel=80" % (contig.split('/')[-1], a, prefix)
    cmd+=" && pileup.sh in=/outdir/%s.aln.sam.gz out=/outdir/%s.cov.txt\'"%(prefix,prefix)
    print(cmd)
    subprocess.call(cmd,shell=True)

if __name__=="__main__":
    parser = argparse.ArgumentParser("Calculate contig coverage")
    parser.add_argument("-p1","--pe1",help="R1 fastq file",required=True)
    parser.add_argument("-p2", "--pe2", help="R2 fastq file",default=None)
    parser.add_argument("-c","--contig", help="contig fasta file",required=True)
    parser.add_argument("-o","--outdir",help="Output directory",default=os.getcwd())
    parser.add_argument("-p","--prefix",help="Prefix of output files",required=True)
    args = parser.parse_args()
    run(args.contig,args.pe1,args.outdir,args.prefix,args.pe2)