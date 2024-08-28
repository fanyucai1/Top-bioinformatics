import os
import sys
import subprocess
import argparse


docker="meta:latest"
def run(fa,prefix,outdir):
    fa=os.path.abspath(fa)
    in_dir=os.path.dirname(fa)
    outdir=os.path.abspath(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    cmd=("docker run -v %s:/raw_data/ -v %s:/outdir/ %s sh -c \'export PATH=/opt/conda/envs/rgi/bin/:$PATH && prodigal -f gff -i /raw_data/%s -o /outdir/%s.nt.fa -a /outdir/%s.nr.fa -p meta\'"
         %(in_dir,outdir,docker,fa.split("/")[-1],prefix,prefix))
    print(cmd)
    subprocess.check_call(cmd,shell=True)

if __name__ == '__main__':
    parser=argparse.ArgumentParser("Fast, reliable protein-coding gene prediction for prokaryotic genomes.")
    parser.add_argument("-i","--input",help="fasta genome sequence",required=True)
    parser.add_argument("-p","--prefix",help="prefix of output files",required=True)
    parser.add_argument("-o","--outdir",help="output directory",required=True)
    args=parser.parse_args()
    run(args.input,args.prefix,args.outdir)