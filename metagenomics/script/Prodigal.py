import os
import sys
import subprocess
import argparse

docker_name="mngs:latest"
parser=argparse.ArgumentParser("Fast, reliable protein-coding gene prediction for prokaryotic genomes.")
parser.add_argument("-i","--input",help="fasta genome sequence",required=True)
parser.add_argument("-o","--outdir",help="output directory",required=True)
args=parser.parse_args()

infile=os.path.abspath(args.input)
if not os.path.exists(args.outdir):
    subprocess.check_call("mkdir -p %s"%(args.outdir),shell=True)
args.outdir=os.path.abspath(args.outdir)

filename=infile.split("/")[-1]
dirname=os.path.dirname(infile)
cmd="docker run -v %s:/raw_data/ -v %s:/outdir/ %s "%(dirname,args.outdir,docker_name)

cmd+="prodigal_v2.6.3 -i /raw_data/%s -o /outdir/nt.fa -a /outdir/nr.fa -p meta"%(filename)
print(cmd)
subprocess.check_call(cmd,shell=True)
