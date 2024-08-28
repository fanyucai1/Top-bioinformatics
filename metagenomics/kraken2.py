#Lu J, Rincon N, Wood D E, et al. Metagenome analysis using the Kraken software suite[J]. Nature protocols, 2022, 17(12): 2815-2839.
#Shen Z, Robert L, Stolpman M, et al. A genome catalog of the early-life human skin microbiome[J]. Genome Biology, 2023, 24(1): 252.
import sys
import os
import subprocess
import argparse

docker="meta:latest"
def run(pe1,index,prefix,outdir,pe2=None,read_length=150):
    pe1 = os.path.abspath(pe1)
    in_dir = os.path.dirname(pe1)
    outdir = os.path.abspath(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    a = pe1.split("/")[-1]
    cmd = ("docker run -v %s:/raw_data/ -v %s:/ref/ -v %s:/outdir/ %s "
           "sh -c \'kraken2 --db /ref/ --threads 24 --output /outdir/%s.txt --minimum-base-quality 20 --report /outdir/%s.report.txt")%(in_dir,os.path.abspath(index),outdir,docker,prefix,prefix)
    if pe2 is not None:
        pe2 = os.path.abspath(pe2)
        if in_dir != os.path.dirname(pe2):
            print("read1 and reads2 must be in the same directory.")
            exit()
        else:
            b = pe2.split("/")[-1]
            cmd+=" --paired /raw_data/%s /raw_data/%s"%(a,b)
    else:
        cmd+=" /raw_data/%s"%(a)
    #Run Bracken for Abundance Estimation of Microbiome Samples
    cmd+=" && bracken -d /ref/ -i /outdir/%s.report.txt -r %s -o /outdir/%s.bracken -w /outdir/%s.breport -t 10"%(prefix,read_length,prefix,prefix)
    #Generate Krona Plots
    cmd+=(" && kreport2krona.py -r /outdir/%s.breport -o /outdir/%s.krona.txt --no-intermediate-ranks && "
          "ktImportText /outdir/%s.krona.txt -o /outdir/%s.krona.html\'")%(prefix,prefix,prefix,prefix)
    print(cmd)
    subprocess.check_call(cmd,shell=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser("Classified out option on the Kraken database,")
    parser.add_argument("-p1", "--pe1", help="5' reads", required=True)
    parser.add_argument("-r","--read_length", help="Read length", required=True,default=150)
    parser.add_argument("-p2", "--pe2", help="3' reads",default=None)
    parser.add_argument("-i", "--index", help="directory contains kraken2 index", required=True)
    parser.add_argument("-o", "--outdir", help="output directory", required=True)
    parser.add_argument("-p", "--prefix", help="prefix of output", required=True)
    args = parser.parse_args()
    run(args.pe1,args.index,args.prefix,args.outdir,args.pe2,args.read_length)
