import os
import subprocess
import argparse

docker_name="meta:latest"
parser=argparse.ArgumentParser("Filter human host and phix sequence.")
parser.add_argument("-p1","--pe1",help="5' reads",required=True)
parser.add_argument("-p2","--pe2",help="3' reads",required=True)
parser.add_argument("-i","--index",help="directory contains bowtie2 index",required=True)
parser.add_argument("-o","--outdir",help="output directory",required=True)
parser.add_argument("-p","--prefix",help="prefix of output",required=True)
args=parser.parse_args()

############prepare input##########################
args.pe1=os.path.abspath(args.pe1)
args.pe2 = os.path.abspath(args.pe2)
in_dir=os.path.dirname(args.pe1)
if in_dir!=os.path.dirname(args.pe2):
    print("read1 and reads2 must be in the same directory.")
    exit()
a=args.pe1.split("/")[-1]
b=args.pe2.split("/")[-1]
args.outdir=os.path.abspath(args.outdir)
if not os.path.exists(args.outdir):
    subprocess.check_call('mkdir -p %s'%(args.outdir),shell=True)
args.index=os.path.abspath(args.index)
reference_dir=os.path.abspath(args.index)
######################################
#index prefix
host_index=""
for i in os.listdir(args.index):
    if i.endswith(".1.bt2"):
        host_index=i.split(".1.bt2")[0]
print(host_index)
cmd="docker run -v %s:/raw_data/ -v %s:/reference/ -v %s:/outdir/ %s "%(in_dir,reference_dir,args.outdir,docker_name)
cmd+="sh -c \"/software/bowtie2-2.4.5-linux-x86_64/bowtie2 --very-sensitive-local --no-sq -p 48 -x /reference/%s -1 //raw_data/%s -2 /raw_data/%s " \
    "--un-conc /outdir/%s.fastq -S /outdir/%s.mapped.sam && rm -rf /outdir/%s.mapped.sam\"" \
     %(host_index,a,b,args.prefix,args.prefix,args.prefix)
print(cmd)
subprocess.check_call(cmd,shell=True)