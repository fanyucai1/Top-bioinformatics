import sys,os
import subprocess
import argparse


def run(fa,outdir,prefix):
    fa=os.path.abspath(fa)
    outdir=os.path.abspath(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    out=os.path.join(outdir,prefix)
    cmd= "cd-hit-est -i %s -o %s.fasta -c 0.95 -n 5 -g 1 -aS 0.8 -T 0" % (fa,out)
    subprocess.call(cmd,shell=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser("cluster similar sequence to reduce redundancy")
    parser.add_argument("-f", "--fasta", help="fasta sequence", required=True)
    parser.add_argument("-o", "--outdir", help="output directory", required=True)
    parser.add_argument("-p", "--prefix", help="prefix of output", required=True, default="no_redundancy")
    args = parser.parse_args()
    run(args.fasta,args.outdir,args.prefix)