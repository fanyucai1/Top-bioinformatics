# Lu J, Rincon N, Wood D E, et al. Metagenome analysis using the Kraken software suite[J]. Nature protocols, 2022, 17(12): 2815-2839.
# Bush S J, Connor T R, Peto T E A, et al. Evaluation of methods for detecting human reads in microbial sequencing datasets[J]. Microbial genomics, 2020, 6(7): e000393.
import os
import subprocess
import argparse

docker="meta:latest"

def run(pe1,index,outdir,prefix,pe2=None,thread=24):
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

    cmd = ("docker run -v %s:/raw_data/ -v %s:/ref/ -v %s:/outdir/ %s "
           "sh -c \'bowtie2 --very-sensitive -p %s -x /ref/%s ") % (in_dir, os.path.abspath(index), outdir, docker,thread,host_index)
    if pe2 is not None:
        pe2 = os.path.abspath(pe2)
        if in_dir != os.path.dirname(pe2):
            print("read1 and reads2 must be in the same directory.")
            exit()
        else:
            b = pe2.split("/")[-1]
            cmd+= "-1 /raw_data/%s -2 /raw_data/%s --un-conc-gz /outdir/%s.fastq.gz" % (a,b,prefix)
    else:
        cmd+="-U /raw_data/%s --un-gz /outdir/%s.fastq.gz"%(a,prefix)
    cmd+=" -S /outdir/%s.sam > /outdir/%s.bowtie2_output.log 2>&1\'"%(prefix,prefix)
    print(cmd)
    subprocess.check_call(cmd,shell=True)


if __name__=="__main__":
    parser=argparse.ArgumentParser("Filter human host and phix sequence.")
    parser.add_argument("-p1","--pe1",help="5' reads",required=True)
    parser.add_argument("-p2","--pe2",help="3' reads",default=None)
    parser.add_argument("-i","--index",help="directory contains bowtie2 index",required=True)
    parser.add_argument("-t","--thread",help="number of alignment threads to launch",default=24,type=int)
    parser.add_argument("-o","--outdir",help="output directory",required=True)
    parser.add_argument("-p","--prefix",help="prefix of output",required=True)
    args=parser.parse_args()
    run(args.pe1, args.index, args.outdir, args.prefix, args.pe2,args.thread)