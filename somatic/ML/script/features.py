import os
import sys
import re
import argparse
import subprocess
from Bio import SeqIO


def vcf2bed(vcf,prefix,outdir=os.getcwd(),length=50):
    out=outdir+"/"+prefix
    infile=open(vcf,"r")
    outfile=open("%s.bed"%(out),"w")
    for line in infile:
        if not line.startswith("#"):
            line=line.strip("\n")
            array=line.split("\t")
            outfile.write("%s\t%s\t%s\n"%(int(array[0]),int(array[1])-1-50,int(array[1])-1+50))
    infile.close()
    outfile.close()
def bed2fasta(ref,bed,prefix,outdir=os.getcwd()):
    out = outdir + "/" + prefix
    cmd='bedtools getfasta -fi %s -bed %s -fo %s.fasta'%(ref,bed,out)
    subprocess.check_call(cmd,shell=True)

def fasta2gc(ref):
    infile = open(ref, 'r')
    GC=[]
    for record in SeqIO.parse(infile, 'fasta'):
        count = 0
        totalcount = 0
        print(record.id)
        for nt in record.seq:
            totalcount = totalcount + 1
            if nt == 'G' or nt == 'C':
                count = count + 1
        percent = count / totalcount * 100
        GC.append(percent)
    infile.close()
    return GC

### Extract the mapping quality,Position list files contain two columns (chromosome and position) and start counting from 1. BED files contain at least 3 columns (chromosome, start and end position) and are 0-based half-open.
def MAPQ(ref,bam,pos_bed,outdir,prefix):
    out=outdir+"/"+prefix
    cmd="samtools mpileup -aa -R -B -s -Q 20 -f %s -l %s %s >%s.map.txt"%(ref,pos_bed,bam,out)
    subprocess.check_call(cmd,shell=True)



