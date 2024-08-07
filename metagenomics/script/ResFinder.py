import sys
import os
import subprocess
import argparse

docker_name="mngs:latest"

parser=argparse.ArgumentParser("\nResFinder identifies acquired antimicrobial resistance genes in total or partial sequenced isolates of bacteria.\n")
parser.add_argument("-p1","--pe1",help="5 reads",required=True)
parser.add_argument("-p2","--pe2",help="3 reads",required=True)
parser.add_argument("-o","--outdir",help="output directory",required=True)
parser.add_argument("-r","--reference",help="path database of ResFinder",required=True)
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
args.reference=os.path.abspath(args.reference)
##############################################################################
cmd="docker run -v %s:/raw_data/ -v %s:/reference/ -v %s:/outdir/ %s "%(in_dir,args.reference,args.outdir,docker_name)
cmd+="sh -c \"export GIT_PYTHON_REFRESH=quiet && export PATH=/software/ncbi-blast-2.13.0+/bin/:$PATH && " \
     "/software/python3/Python-v3.10.5/bin/python3 /software/resfinder/run_resfinder.py " \
     "-ifq /raw_data/%s /raw_data/%s -o /outdir/ " \
     "--species \'Other\' " \
     "-db_res /reference/resfinder_db -acq\""%(a,b)

print(cmd)

subprocess.check_call(cmd,shell=True)