import os,re
import subprocess
import argparse

docker="meta:latest"
def run_fa(fna,outdir,index,prefix,type):
    fna=os.path.abspath(fna)


def run_reads(pe1,outdir,index,prefix,pe2=None):
    pe1 = os.path.abspath(pe1)
    in_dir = os.path.dirname(pe1)
    outdir = os.path.abspath(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    a = pe1.split("/")[-1]
    cmd = "docker run -v %s:/raw_data/ -v %s:/ref/ -v %s:/outdir/ %s sh -c \' export PATH=/opt/conda/envs/rgi/bin/:$PATH && rgi load --debug --local"%(in_dir,index,outdir,docker)
    for i in os.listdir(index):
        if i.startswith("card_database_") and i.endswith("fasta"):
            if i.endswith("_all.fasta"):
                cmd+=" --card_annotation_all_models /ref/%s"%(i)
            else:
                cmd += " --card_annotation /ref/%s" % (i)
        if i.startswith("wildcard_database_") and i.endswith("fasta"):
            if i.endswith("_all.fasta"):
                cmd+=" --wildcard_annotation_all_models /ref/%s"%(i)
            else:
                cmd += " --wildcard_annotation /ref/%s" % (i)
    cmd+=" --card_json /ref/card.json --wildcard_index /ref/wildcard/index-for-model-sequences.txt --kmer_database /ref/wildcard/61_kmer_db.json --amr_kmers /ref/wildcard/all_amr_61mers.txt --kmer_size 61"

    if pe2 is not None:
        pe2=os.path.abspath(pe2)
        b = pe2.split("/")[-1]
        if in_dir != os.path.dirname(pe2):
            print("Sample pe1 and pe2 reads must be in the same directory.")
            exit(1)
        else:
            cmd+=" && rgi bwt --read_one /raw_data/%s --read_two /raw_data/%s --output_file /outdir/%s --local --include_other_models -n 48"%(a,b,prefix)
    else:
        cmd += " && rgi bwt --read_one /raw_data/%s --output_file /outdir/%s --local --include_other_models -n 48" % (a, prefix)
    print(cmd)
    subprocess.check_call(cmd, shell=True)



if __name__ == "__main__":
    parser = argparse.ArgumentParser("The Resistance Gene Identifier (RGI).")
    parser.add_argument("-t","--type",type=str,help="sequence type",choices=["contig","protein"])
    parser.add_argument("-f","--fna",help="FASTA file",required=True)
    parser.add_argument("-o","--outdir",type=str,default=os.getcwd(),help="output directory")
    parser.add_argument("-p","--prefix",type=str,help="prefix for output files")
    parser.add_argument("-i", "--index", help="directory of CARD Reference Data", required=True)
    parser.add_argument("-p1", "--pe1", help="comma-separated list of fasta/q paired-end #1 files")
    parser.add_argument("-p2", "--pe2", help="comma-separated list of fasta/q paired-end #2 files")
    args = parser.parse_args()