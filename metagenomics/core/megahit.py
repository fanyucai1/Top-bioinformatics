import os
import subprocess
import argparse

def run(pe1,outdir,prefix,pe2=None):
    pe1=os.path.abspath(pe1)
    outdir=os.path.abspath(outdir)
    out=os.path.join(outdir,prefix)
    cmd=""
    if pe2 is None:
        cmd= "megahit -r %s -o %s --out-prefix %s --min-contig-len 500 -t 24"% (pe1,outdir,prefix)
    else:
        pe2=os.path.abspath(pe2)
        cmd= "megahit -1 %s -2 %s -o %s --out-prefix %s --min-contig-len 500 -t 24"% (pe1, pe2,outdir,prefix)

    subprocess.check_call(cmd,shell=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser("MEGAHIT is an ultra-fast and memory-efficient NGS assembler")
    parser.add_argument("-p1", "--pe1", help="R1 fastq file", required=True)
    parser.add_argument("-p2", "--pe2", help="R2 fastq file",default=None)
    parser.add_argument("-o", "--outdir", help="output directory", required=True)
    parser.add_argument("-p", "--prefix", help="prefix of output", required=True)
    args = parser.parse_args()
    run(args.pe1,args.outdir,args.prefix,args.pe2)