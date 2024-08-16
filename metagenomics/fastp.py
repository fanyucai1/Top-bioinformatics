import os
import subprocess
import argparse
import json

docker="meta:latest"
#     remove adaptors
#     quality filtering of reads
#     removal of low-quality reads(q < 20)
#     removal of short reads ( < 36 bp)
#     deduplication for FASTQ data
def run(pe1,outdir,prefix,pe2=None):
    pe1 = os.path.abspath(pe1)
    in_dir = os.path.abspath(pe1)
    outdir = os.path.abspath(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    a = pe1.split("/")[-1]

    cmd = "docker run -v %s:/raw_data/ -v %s:/outdir/ -e \'export PATH=/opt/conda/bin:$PATH\' %s " % (in_dir,outdir, docker)
    cmd += ("fastp -i /raw_data/%s -o /outdir/%s.qc.R1.fq.gz "
            "--length_required 36 --dedup --thread 16 --low_complexity_filter "
            "--html /outdir/%s.fastp.html --json /outdir/%s.fastp.json ") % (a, prefix, prefix, prefix)
    if pe2 is not None:
        pe2=os.path.abspath(pe2)
        if in_dir != os.path.dirname(pe2):
            print("read1 and reads2 must be in the same directory.")
            exit()
        b = pe2.split("/")[-1]
        cmd += ("-I /raw_data/%s -O /outdir/%s.qc.R2.fq.gz") % (b,prefix)
    print(cmd)
    subprocess.check_call(cmd, shell=True)
    out=outdir+'/'+prefix
    outfile = open("%s.fastp.tsv" % (out), "w")
    outfile.write("SampleID\tTotal_reads\tTotal_bases\tQ20_rate\tQ30_rate\tgc_content\tTotal_reads(clean)\tTotal_bases\tQ20_rate\tQ30_rate\tgc_content\n")
    with open("%s.fastp.json"%out, "r") as load_f:
        load_dict = json.load(load_f)
        outfile.write("%s\t" % (prefix))
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
    parser=argparse.ArgumentParser("Run fastp quality control.")
    parser.add_argument("-1","--R1",help="R1 fastq.gz",required=True)
    parser.add_argument("-2","--R2",help="R2 fastq.gz",default=None)
    parser.add_argument("-p","--prefix",help="prefix of output",required=True)
    parser.add_argument("-o","--outdir",help="output directory",required=True)
    args=parser.parse_args()
    run(args.R1,args.outdir,args.prefix,args.R2)