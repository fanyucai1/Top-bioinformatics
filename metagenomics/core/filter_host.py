import os
import subprocess
import argparse
import re

docker="meta:latest"
def run(pe1,index,outdir,prefix,pe2=None):
    pe1 = os.path.abspath(pe1)
    in_dir = os.path.abspath(pe1)
    outdir = os.path.abspath(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    a = pe1.split("/")[-1]
    out=outdir+"/"+prefix
    cmd=""
    if pe2 is None:
        cmd= "bowtie2 --very-sensitive-local -p 48 -x %s -1 %s --un-conc-gz %s.fastq.gz -S %s.sam" % (index,pe1,out,out)
    else:
        cmd= "bowtie2 --very-sensitive-local -p 48 -x %s -1 %s -2 %s --un-conc-gz %s.fastq.gz -S %s.sam" % (index,pe1,pe2,out,out)
    subprocess.check_call(cmd,shell=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser("Filter human host and phix sequence.")
    parser.add_argument("-p1", "--pe1", help="5' reads", required=True)
    parser.add_argument("-p2", "--pe2", help="3' reads", default=None)
    parser.add_argument("-i", "--index", help="directory contains bowtie2 index", required=True)
    parser.add_argument("-o", "--outdir", help="output directory", required=True)
    parser.add_argument("-p", "--prefix", help="prefix of output", required=True)
    args = parser.parse_args()
    run(args.pe1,args.index,args.outdir,args.prefix,args.pe2)