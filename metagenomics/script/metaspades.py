import os
import subprocess
import argparse

docker_name="mngs:latest"
parser=argparse.ArgumentParser("assemble genome using metaSPAdes.")
parser.add_argument("-p1","--pe1",help="5' reads",required=True)
parser.add_argument("-p2","--pe2",help="3' reads",required=True)
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
##############################################################################2022-Contribution of Clinical Metagenomics to the Diagnosis of Bone and Joint Infections.pdf
cmd="docker run -v %s:/raw_data/ -v %s:/outdir/ %s "%(in_dir,args.outdir,docker_name)

cmd+="sh -c \"export PATH=/software/python3/Python-v3.7.0/bin/:/software/SPAdes-3.15.4-Linux/bin:$PATH && " \
     "/software/seqtk-master/seqtk mergepe /raw_data/%s /raw_data/%s >/outdir/%s.merge.fastq && " \
     "spades.py -k 21,33,55,77,99,127 --threads 24 --12 /outdir/%s.merge.fastq --meta -o /outdir/ \""%(a,b,args.prefix,args.prefix)

subprocess.check_call(cmd,shell=True)

infile=open("%s/scaffolds.fasta"%(args.outdir),"r")
outfile1=open("%s/scaffolds_500bp.fasta"%(args.outdir),"w")
outfile2=open("%s/scaffolds_1000bp.fasta"%(args.outdir),"w")
fa,id={},""
for line in infile:
    line=line.strip()
    if line.startswith(">"):
        id=line
        fa[id]=""
    else:
        fa[id]+=line
infile.close()
for key in fa:
    if int(key.split("_")[3])>=500:
        outfile1.write("%s\n%s\n"%(key,fa[key]))
    if int(key.split("_")[3]) >= 1000:
        outfile2.write("%s\n%s\n" % (key, fa[key]))
outfile1.close()
outfile2.close()


