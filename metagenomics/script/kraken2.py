import os
import subprocess
import argparse

docker_name="mngs:latest"
parser=argparse.ArgumentParser("Classified out option on the miniKraken database,")
parser.add_argument("-p1","--pe1",help="5' reads",required=True)
parser.add_argument("-p2","--pe2",help="3' reads",required=True)
parser.add_argument("-i","--index",help="directory contains kraken2 index",required=True)
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
reference_dir=os.path.abspath(args.index)
#######################################

cmd="docker run -v %s:/raw_data/ -v %s:/reference/ -v %s:/outdir/ %s "%(in_dir,reference_dir,args.outdir,docker_name)
cmd+="sh -c \"export PATH=/software/kraken2-2.1.2/:$PATH && kraken2 --db /reference/ --threads 24 --output /outdir/%s.txt " \
     "--minimum-base-quality 20 --report /outdir/%s.report.txt --paired /raw_data/%s /raw_data/%s \"" \
     %(args.prefix,args.prefix,a,b)

print(cmd)
subprocess.check_call(cmd,shell=True)

#######################################krakentools
cmd="docker run -v %s:/outdir/ %s "%(args.outdir,docker_name)
cmd+="sh -c \'/software/python3/Python-v3.10.5/bin/python3.10 /software/KrakenTools-1.2/kreport2krona.py " \
     "-r /outdir/%s.report.txt -o /outdir/%s.kraken2krona.txt && " \
     "ktImportText /outdir/%s.kraken2krona.txt -o /outdir/%s.krona.html \' "%(args.prefix,args.prefix,args.prefix,args.prefix)
print(cmd)
subprocess.check_call(cmd,shell=True)