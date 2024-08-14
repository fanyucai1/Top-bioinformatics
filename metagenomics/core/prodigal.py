import sys,os
import subprocess
import argparse


def run(fa,outdir,prefix):
    fa=os.path.abspath(fa)
    outdir=os.path.abspath(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    out=os.path.join(outdir,prefix)
    cmd= "prodigal -i %s -o %s.nucl.fa -a %s.pro.fa -p meta" % (fa,out,out)
    subprocess.call(cmd,shell=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser("Fast, reliable protein-coding gene prediction for prokaryotic genomes.")
    parser.add_argument("-f", "--fna", help="fasta genome sequence", required=True)
    parser.add_argument("-o", "--outdir", help="output directory", required=True)
    args = parser.parse_args()
    run(args.fna,args.outdir,args.prefix)