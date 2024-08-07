import os
import sys
import subprocess
import re
import argparse


parser=argparse.ArgumentParser("cluster similar sequence to reduce redundancy")
parser.add_argument("-f","--fasta",help="fasta sequence",required=True)
parser.add_argument("-o","--outdir",help="output directory",required=True)
parser.add_argument("-p","--prefix",help="prefix of output",required=True,default="no_redundancy")
args=parser.parse_args()

docker_name="fanyucai1/mngs:latest"

args.fasta=os.path.abspath(args.fasta)
args.outdir=os.path.abspath(args.outdir)
if not os.path.exists(args.outdir):
    subprocess.check_call("mkdir -p %s"%(args.outdir),shell=True)


cmd="docker run -v %s:/raw_data/ -v %s:/outdir/ %s "%(os.path.dirname(args.fasta),args.outdir,docker_name)
cmd+="/software/cd-hit-v4.8.1-2019-0228/cd-hit-est -i /raw_data/%s -o /outdir/%s.fasta "%(args.fasta.split("/")[-1],args.prefix)
cmd+="-c 0.95 -n 5 -g 1 -aS 0.8 -T 0"

print(cmd)

subprocess.check_call(cmd,shell=True)