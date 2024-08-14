import os
import subprocess
import argparse
import re

def run(R1,index,outdir,prefix,R2=None):
    R1=os.path.abspath(R1)
    index = os.path.abspath(index)
    out=os.path.abspath(outdir)+"/"+prefix
    cmd=""
    if R2 is None:
        cmd="kraken2 --db %s --threads 24 --output %s.txt --minimum-base-quality 20 --report %s.report.txt %s && "%(index,out,out,R1)
    else:
        R2=os.path.abspath(R2)
        cmd="kraken2 --db %s --threads 24 --output %s.txt --minimum-base-quality 20 --report %s.report.txt --paired %s %s && "%(index,out,out,R1,R2)
    cmd += "kreport2krona.py -r %s.report.txt -o %s.kraken2krona.txt && ktImportText %s.kraken2krona.txt -o %s.krona.html" % (out, out, out, out)
    subprocess.check_call(cmd, shell=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser("Classified out option on the miniKraken database,")
    parser.add_argument("-p1", "--pe1", help="5' reads", required=True)
    parser.add_argument("-p2", "--pe2", help="3' reads", default=None)
    parser.add_argument("-i", "--index", help="directory contains kraken2 index", required=True)
    parser.add_argument("-o", "--outdir", help="output directory", required=True)
    parser.add_argument("-p", "--prefix", help="prefix of output", required=True)
    args = parser.parse_args()
    run(args.pe1,args.pe2,args.index,args.outdir,args.prefix)