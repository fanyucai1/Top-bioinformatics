import os
import subprocess
import argparse
import time
from multiprocessing import Process

docker_name="mngs:latest"
parser=argparse.ArgumentParser("Use seqtk downsizing the samples.")
parser.add_argument("-p1","--pe1",help="5' reads",required=True)
parser.add_argument("-p2","--pe2",help="3' reads",required=True)
parser.add_argument("-o","--outdir",help="output directory",required=True)
parser.add_argument("-n","--number",help="the number sequence you want",default=1000000)
parser.add_argument("-p","--prefix",help="prefix of output",required=True)
args=parser.parse_args()
#################################################
def shell_run(x):
    subprocess.check_call(x, shell=True)
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
######################################
cmd="docker run -v %s:/raw_data/ -v %s:/outdir/ %s "%(in_dir,args.outdir,docker_name)

shell1=cmd+"sh -c \"cd /outdir/ && /software/seqtk-master/seqtk sample -s100 /raw_data/%s %s >%s.sub.R1.fq\""%(a,args.number,args.prefix)
shell2=cmd+"sh -c \"cd /outdir/ && /software/seqtk-master/seqtk sample -s100 /raw_data/%s %s >%s.sub.R2.fq\""%(b,args.number,args.prefix)

p1 = Process(target=shell_run, args=(shell1,))
p2 = Process(target=shell_run, args=(shell2,))
p1.start()
p2.start()
p1.join()
p2.join()
