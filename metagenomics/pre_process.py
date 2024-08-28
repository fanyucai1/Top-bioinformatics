import os
import sys
import re
import subprocess
import argparse

docker="meta:latest"
def run(pe1,outdir,prefix,kraken2,bowtie2,pe2=None):
    pe1=os.path.abspath(pe1)
    in_dir = os.path.dirname(pe1)
    a=pe1.split('/')[-1]
    outdir=os.path.abspath(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    ###################################################fastp
    os.makedirs("%s/fastp" % outdir)
    cmd = "docker run -v %s:/raw_data/ -v %s:/outdir/ %s " % (in_dir, outdir, docker)
    cmd += ("sh -c \'export PATH=/opt/conda/bin:$PATH && fastp -i /raw_data/%s -o /outdir/%s.qc.R1.fq.gz "
            "--length_required 36 --dedup --thread 24 --low_complexity_filter --qualified_quality_phred 30 "
            "--html /outdir/%s.fastp.html --json /outdir/%s.fastp.json ") % (a, prefix, prefix, prefix)
    if pe2 is not None:
        pe2=os.path.abspath(pe2)
        b=pe2.split('/')[-1]
        if in_dir != os.path.dirname(pe2):
            print("read1 and reads2 must be in the same directory.")
            exit()
        b = pe2.split("/")[-1]
        cmd += ("-I /raw_data/%s -O /outdir/%s.qc.R2.fq.gz\'") % (b, prefix)
    else:
        cmd = '\''
    print(cmd)
    subprocess.check_call(cmd, shell=True)
    ###################################################bowtie2
    bowtie2 = os.path.abspath(bowtie2)
    os.makedirs("%s/bowtie2" % outdir)
    host_index = ""
    for i in os.listdir(bowtie2):  # bowtie2-build outputs a set of 6 files with suffixes .1.bt2, .2.bt2, .3.bt2, .4.bt2, .rev.1.bt2, and .rev.2.bt2.
        if i.endswith(".rev.2.bt2"):
            host_index = i.split(".rev.2.bt2")[0]
    cmd = ("docker run -v %s:/raw_data/ -v %s:/ref/ -v %s:/outdir/ %s "
              "sh -c \'export PATH=/opt/conda/envs/rgi/bin:$PATH && "
           "bowtie2 --very-sensitive-local -p 48 -x /ref/%s -1 /raw_data/%s ") % (in_dir, os.path.abspath(bowtie2), outdir, docker, host_index, a)
    if pe2 is not None:
        pe2 = os.path.abspath(pe2)
        if in_dir != os.path.dirname(pe2):
            print("read1 and reads2 must be in the same directory.")
            exit()
        else:
            b = pe2.split("/")[-1]
            cmd += "-2 /raw_data/%s" % (b)
    cmd += " --un-conc-gz /outdir/%s.fastq.gz -S /outdir/%s.sam\'" % (prefix, prefix)
    print(cmd)
    subprocess.check_call(cmd, shell=True)

    os.makedirs("%s/megahit" % outdir)


    kraken2 = os.path.abspath(kraken2)
    os.makedirs("%s/kraken2" % outdir)

