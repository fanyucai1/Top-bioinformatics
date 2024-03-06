import sys
import os
import re
import subprocess
import argparse
import time

def qc(R1,R2,outdir,prefix):

    R1=os.path.abspath(R1)
    R2 = os.path.abspath(R2)
    outdir=os.path.abspath(outdir)
    if not os.path.exists(outdir):
        subprocess.check_call('mkdir -p %s'%(outdir),shell=True)
    out=outdir+"/"+prefix

    cmd = "fastp --in1 %s --in2 %s --out1 %s_1.fastq.gz --out2 %s_2.fastq.gz " \
          "--html %s.html --json %s.json --report_title %s " \
          "--thread 16  --detect_adapter_for_pe --length_required 35 --qualified_quality_phred 20" % (R1, R2, out, out, out, out, out)
    print(cmd)
    subprocess.check_call(cmd,shell=True)

def bwa(R1,R2,ref,outdir,prefix):
    R1=os.path.abspath(R1)
    R2=os.path.abspath(R2)
    outdir=os.path.abspath(outdir)
    if not os.path.exists(outdir):
        subprocess.check_call('mkdir -p %s'%(outdir),shell=True)
    out=outdir+"/"+prefix
    cmd="bwa mem -t 16 %s %s %s| samtools view -@ 16 -Su - | samtools sort -@ 16 - <%s.bam>"%(ref,R1,R2,out)
    print(cmd)
    subprocess.check_call(cmd,shell=True)

def vardict(tumor,normal,ref,outdir,prefix,bed):
    tumor=os.path.abspath(tumor)
    normal=os.path.abspath(normal)
    if not os.path.exists(outdir):
        subprocess.check_call('mkdir -p %s'%(outdir),shell=True)
    out=outdir+"/"+prefix
    cmd="vardict -G %s -t -f 0.10 -N %s -b \"%s|%s\" -c 1 -S 2 -E 3 -g 4 %s  > <output file>"%(ref,prefix,tumor,normal,bed)
