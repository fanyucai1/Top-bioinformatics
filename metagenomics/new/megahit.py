import os
import subprocess
import argparse

docker_name="fanyucai1/mngs:latest"
parser=argparse.ArgumentParser("MEGAHIT is an ultra-fast and memory-efficient NGS assembler")
parser.add_argument("-p1","--pe1",help="R1 fastq file",required=True)
parser.add_argument("-p2","--pe2",help="R2 fastq file",required=True)
parser.add_argument("-o","--outdir",help="output directory",required=True)
parser.add_argument("-p","--prefix",help="prefix of output",required=True)
args=parser.parse_args()

args.pe1=os.path.abspath(args.pe1)
args.pe2=os.path.abspath(args.pe2)
args.outdir=os.path.abspath(args.outdir)
if not os.path.exists(args.outdir):
    subprocess.check_call('mkdir -p %s'%(args.outdir),shell=True)
if os.path.dirname(args.pe1)!=os.path.dirname(args.pe2):
    print("%s and %s must be in the same directory!!!\n"%(args.pe1,args.pe2))
    exit()
in_dir=os.path.dirname(args.pe1)


cmd="docker run -v %s:/raw_data/ -v %s:/outdir/ %s "%(in_dir,args.outdir,docker_name)
cmd+="sh -c \'/software/MEGAHIT-1.2.9-Linux-x86_64-static/bin/megahit" \
     " -1 /raw_data/%s -2 /raw_data/%s -o /megahit/ --out-prefix %s --min-contig-len 500 -t 24 && mv /megahit/* /outdir/\'"\
     %(args.pe1.split("/")[-1], args.pe2.split("/")[-1],args.prefix)

print(cmd)
subprocess.check_call(cmd,shell=True)