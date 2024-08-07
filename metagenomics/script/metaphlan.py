import os
import subprocess
import argparse

docker_name="mngs:latest"
parser=argparse.ArgumentParser("MetaPhlAn2 uses a database of clade-specific marker genes to classify\n")
parser.add_argument("-p1","--pe1",help="5' reads",required=True)
parser.add_argument("-p2","--pe2",help="3' reads",required=True)
parser.add_argument("-i","--index",help="directory contains metaphlan index",required=True)
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
####################################################

cmd="docker run -v %s:/raw_data/ -v %s:/reference/ -v %s:/outdir/ %s "%(in_dir,reference_dir,args.outdir,docker_name)
bowtie2_index=""
for i in os.listdir(reference_dir):
    if i.endswith(".pkl"):
        bowtie2_index=i.split('.pkl')[0]

cmd+="sh -c \"export PATH=/software/python3/Python-v3.10.5/bin/:$PATH && metaphlan /raw_data/%s,/raw_data/%s " \
     "--nproc 24 --bowtie2db /reference/ --bowtie2_exe /software/bowtie2-2.4.5-linux-x86_64/bowtie2 " \
     "--bowtie2out /outdir/%s.bowtie2.bz2 --index %s -t rel_ab_w_read_stats " \
     "--input_type fastq -o /outdir/%s_metaphlan.txt --biom /outdir/%s.biom\""\
     %(a,b,args.prefix,bowtie2_index,args.prefix,args.prefix)
print(cmd)
subprocess.check_call(cmd,shell=True)
