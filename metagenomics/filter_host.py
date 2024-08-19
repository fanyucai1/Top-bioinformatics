#Lu J, Rincon N, Wood D E, et al. Metagenome analysis using the Kraken software suite[J]. Nature protocols, 2022, 17(12): 2815-2839.
import os
import subprocess
import argparse

docker="meta:latest"

def run(pe1,index,outdir,prefix,pe2=None):
    pe1 = os.path.abspath(pe1)
    in_dir = os.path.dirname(pe1)
    outdir = os.path.abspath(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    a = pe1.split("/")[-1]
    host_index = ""
    for i in os.listdir(index):# bowtie2-build outputs a set of 6 files with suffixes .1.bt2, .2.bt2, .3.bt2, .4.bt2, .rev.1.bt2, and .rev.2.bt2.
        if i.endswith(".rev.2.bt2"):
            host_index = i.split(".rev.2.bt2")[0]

    cmd = ("docker run -v %s:/raw_data/ -v %s:/ref/ -v %s:/outdir/ -e \'PATH=/usr/bin/:/opt/conda/envs/rgi/bin:$PATH\' %s "
           "bowtie2 --very-sensitive-local -p 48 -x /ref/%s -1 /raw_data/%s ") % (in_dir, os.path.abspath(index), outdir, docker,host_index,a)
    if pe2 is not None:
        pe2 = os.path.abspath(pe2)
        if in_dir != os.path.dirname(pe2):
            print("read1 and reads2 must be in the same directory.")
            exit()
        b = pe2.split("/")[-1]
        cmd+= "-2 /raw_data/%s" % (b)
    cmd+=" --un-conc-gz /outdir/%s.fastq.gz -S /outdir/%s.sam"%(prefix,prefix)
    print(cmd)
    subprocess.check_call(cmd,shell=True)


if __name__=="__main__":
    parser=argparse.ArgumentParser("Filter human host and phix sequence.")
    parser.add_argument("-p1","--pe1",help="5' reads",required=True)
    parser.add_argument("-p2","--pe2",help="3' reads")
    parser.add_argument("-i","--index",help="directory contains bowtie2 index",required=True)
    parser.add_argument("-o","--outdir",help="output directory",required=True)
    parser.add_argument("-p","--prefix",help="prefix of output",required=True)
    args=parser.parse_args()
    run(args.pe1, args.index, args.outdir, args.prefix, args.pe2)