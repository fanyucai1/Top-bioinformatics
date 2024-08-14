import os
import argparse
import subprocess
import json


def run(pe1,outdir,prefix,pe2=None):
    pe1=os.path.abspath(pe1)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    out=outdir+'/'+prefix
    if pe2 is None:
        cmd = "fastp -i %s -o %s.qc.R1.fq.gz --length_required 36 --dedup --thread 16 --low_complexity_filter --html %s.fastp.html --json %s.fastp.json" % (pe1, out, out, out)
    else:
        pe2=os.path.abspath(pe2)
        cmd = "fastp -i %s -I %s -o %s.qc.R1.fq.gz -O %s.qc.R2.fq.gz --length_required 36 --dedup --thread 16 --low_complexity_filter --html %s.fastp.html --json %s.fastp.json" % (pe1, pe2,out, out, out, out)
    subprocess.check_call(cmd, shell=True)
    outfile = open("%s.fastp.tsv" % (out), "w")
    outfile.write("SampleID\tTotal_reads\tTotal_bases\tQ20_rate\tQ30_rate\tgc_content\tTotal_reads(clean)\tTotal_bases\tQ20_rate\tQ30_rate\tgc_content\n")
    with open("%s.fastp.json"%out, "r") as load_f:
        load_dict = json.load(load_f)
        outfile.write("%s\t" % (args.prefix))
        outfile.write("%s\t%s\t%s\t%s\t%s\t"
                      % (load_dict['summary']['before_filtering']['total_reads'],
                         load_dict['summary']['before_filtering']['total_bases'],
                         load_dict['summary']['before_filtering']['q20_rate'],
                         load_dict['summary']['before_filtering']['q30_rate'],
                         load_dict['summary']['before_filtering']['gc_content']))
        outfile.write("%s\t%s\t%s\t%s\t%s\n"
                      % (load_dict['summary']['after_filtering']['total_reads'],
                         load_dict['summary']['after_filtering']['total_bases'],
                         load_dict['summary']['after_filtering']['q20_rate'],
                         load_dict['summary']['after_filtering']['q30_rate'],
                         load_dict['summary']['after_filtering']['gc_content']))

    outfile.close()

if __name__=="__main__":
    parser=argparse.ArgumentParser("Run fastp.")
    parser.add_argument("-1","--R1",help="R1 fastq.gz",required=True)
    parser.add_argument("-2","--R2",help="R2 fastq.gz",default=None)
    parser.add_argument("-p","--prefix",help="prefix of output",required=True)
    parser.add_argument("-o","--outdir",help="output directory",required=True)
    parser.add_argument("-c", "--config", help="config file", required=True)
    args=parser.parse_args()
    run(args.R1,args.outdir,args.prefix,args.R2)