import os
import subprocess
import argparse

docker="meta:latest"
parser = argparse.ArgumentParser("")
parser.add_argument('-c','--contig',help='contig fasta',required=True)
parser.add_argument('-r','--ref',help='staramr database directory',required=True)
parser.add_argument('-p','--prefix',help='prefix of output',required=True)
parser.add_argument('-o','--outdir',help='output directory',default=os.getcwd())
args = parser.parse_args()

if not os.path.exists(args.outdir):
    os.makedirs(args.outdir)
args.outdir=os.path.abspath(args.outdir)
args.contig=os.path.abspath(args.contig)
args.ref=os.path.abspath(args.ref)
cmd=f'docker run -v {args.ref}:/ref -v {os.path.dirname(args.contig)}:/raw_data/ -v {args.outdir}:/outdir {docker}'
cmd+=f' sh -c \'rm -rf /outdir/{args.prefix}.AMR && staramr search -d /ref/ -o /outdir/{args.prefix}.AMR /raw_data/{args.contig.split("/")[-1]}\''
print(cmd)
subprocess.check_call(cmd,shell=True)