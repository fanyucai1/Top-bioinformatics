import os
import subprocess
import argparse

docker="meta:latest"
parser=argparse.ArgumentParser("MEGAHIT is an ultra-fast and memory-efficient NGS assembler")
parser.add_argument("-p1","--pe1",help="comma-separated list of fasta/q paired-end #1 files",required=True)
parser.add_argument("-p2","--pe2",help="comma-separated list of fasta/q paired-end #2 files",default=None)
parser.add_argument("-o","--outdir",help="output directory",required=True)
parser.add_argument("-p","--prefix",help="prefix of output",required=True)
args=parser.parse_args()

args.pe1=os.path.abspath(args.pe1)
in_dir=os.path.dirname(args.pe1)

args.outdir=os.path.abspath(args.outdir)
if not os.path.exists(args.outdir):
    subprocess.check_call('mkdir -p %s'%(args.outdir),shell=True)

cmd = "docker run -v %s:/raw_data/ -v %s:/outdir/ %s sh -c \'megahit" % (in_dir,args.outdir, docker)

if args.pe2!="None":
    args.pe2 = os.path.abspath(args.pe2)
    if os.path.dirname(args.pe1)!=os.path.dirname(args.pe2):
        print("%s and %s must be in the same directory!!!\n"%(args.pe1,args.pe2))
        exit()
    cmd+=" -1 /raw_data/%s -2 /raw_data/%s" %(args.pe1.split("/")[-1], args.pe2.split("/")[-1])
else:
    cmd+=" --read /raw_data/%s"
cmd+=" -o /outdir/megahit_%s/ --out-prefix %s -m 0.8 --min-contig-len 500 -t 64"%(args.prefix,args.prefix)
print(cmd)
subprocess.check_call(cmd,shell=True)