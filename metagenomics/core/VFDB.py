import os
import subprocess
import argparse


def run(fa,index,outdir,prefix):
    fa=os.path.abspath(fa)
    outdir=os.path.abspath(outdir)
    out=outdir+"/"+prefix
    cmd="blastp "


if __name__ == '__main__':
    parser = argparse.ArgumentParser("This script is used to run the VFDB tool.")
    parser.add_argument("-f",'--fa',help="protein sequence",required=True)
    parser.add_argument("-o",'--outdir',help="output directory",required=True)
    parser.add_argument("-i","--index",help="blastp index file",required=True)
    parser.add_argument("-p",'--prefix',help="prefix of output files",required=True)
    args = parser.parse_args()
    run(args.fa,args.outdir,args.prefix)