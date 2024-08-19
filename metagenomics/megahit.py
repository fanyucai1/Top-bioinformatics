import os,sys,re
import subprocess
import argparse

docker="meta:latest"
def run(pe1,prefix,outdir,pe2=None):
    array=pe1.split(",")
    in_dir=os.path.dirname(os.path.abspath(array[0]))
    a="/raw_data/"+os.path.abspath(array[0]).split("/")[-1]
    outdir =os.path.abspath(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    cmd="docker run -v %s:/raw_data/ -v %s:/outdir/ -e PATH=/usr/bin/:/opt/conda/bin:$PATH %s megahit"%(in_dir,outdir,docker)
    for i in range(1,len(array)):
        if in_dir!=os.path.dirname(os.path.abspath(array[i])):
            print("All sample reads must be in the same directory.")
            exit(1)
        a+=","+"/raw_data/"+os.path.abspath(array[i]).split("/")[-1]
    if pe2 is not None:
        b=""
        array = pe2.split(",")
        for i in range(0,len(array)):
            if in_dir!=os.path.dirname(os.path.abspath(array[i])):
                print("All sample reads must be in the same directory.")
                exit(1)
            if i==0:
                b="/raw_data/"+os.path.abspath(array[0]).split("/")[-1]
            else:
                b+=","+"/raw_data/"+os.path.abspath(array[i]).split("/")[-1]
        cmd+="-1 %s -2 %s "%(a,b)
    else:
        cmd+="--read %s"%(a)
    cmd+="-o /outdir/ --out-prefix %s -m 0.8 --min-contig-len 500 -t 24"%(prefix)
    print(cmd)
    subprocess.call(cmd,shell=True)

if __name__=="__main__":
    parser = argparse.ArgumentParser("MEGAHIT is an ultra-fast and memory-efficient NGS assembler")
    parser.add_argument("-p1", "--pe1", help="comma-separated list of fasta/q paired-end #1 files", required=True)
    parser.add_argument("-p2", "--pe2", help="comma-separated list of fasta/q paired-end #2 files")
    parser.add_argument("-o", "--outdir", help="output directory", required=True)
    parser.add_argument("-p", "--prefix", help="prefix of output", required=True)
    args = parser.parse_args()