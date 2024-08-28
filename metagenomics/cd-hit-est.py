import sys,os
import subprocess
import argparse

docker="meta:latest"
def run(fa,outdir,prefix):
    fa=os.path.abspath(fa)
    outdir=os.path.abspath(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    in_dir=os.path.dirname(fa)
    cmd= ("docker run -v %s:/raw_data/ -v %s:/outdir/ %s sh -c \'export PATH=/opt/conda/bin/:$PATH && "
          "cd-hit-est -i %s -o /outdir/%s.fasta -c 0.95 -n 5 -g 1 -aS 0.8 -T 0\'") % (in_dir,outdir,fa.split('/')[-1],prefix)
    subprocess.call(cmd,shell=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser("cluster similar sequence to reduce redundancy")
    parser.add_argument("-f", "--fasta", help="fasta sequence", required=True)
    parser.add_argument("-o", "--outdir", help="output directory", required=True)
    parser.add_argument("-p", "--prefix", help="prefix of output", required=True, default="no_redundancy")
    args = parser.parse_args()
    run(args.fasta,args.outdir,args.prefix)