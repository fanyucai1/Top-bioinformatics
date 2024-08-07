QC_fastp.py
=========================
::

    remove adaptors
    quality filtering of reads
    removal of low-quality reads(q < 20)
    removal of short reads ( < 36 bp)
    deduplication for FASTQ data

    usage: Quality control [-h] -p1 PE1 -p2 PE2 -o OUTDIR -p PREFIX -a ADPATER

    optional arguments:
      -h, --help            show this help message and exit
      -p1 PE1, --pe1 PE1    5' reads
      -p2 PE2, --pe2 PE2    3' reads
      -o OUTDIR, --outdir OUTDIR
                            output directory
      -p PREFIX, --prefix PREFIX
                            prefix of output
      -a ADPATER, --adpater ADPATER
                            adapter fasta file
filter_host.py
=========================
::

    usage: Filter human host and phix sequence. [-h] -p1 PE1 -p2 PE2 -i INDEX -o OUTDIR -p PREFIX

    optional arguments:
      -h, --help            show this help message and exit
      -p1 PE1, --pe1 PE1    5' reads
      -p2 PE2, --pe2 PE2    3' reads
      -i INDEX, --index INDEX
                            directory contains bowtie2 index
      -o OUTDIR, --outdir OUTDIR
                            output directory
      -p PREFIX, --prefix PREFIX
                            prefix of output

downsize.py
=========================
::

    usage: Use seqtk downsizing the samples. [-h] -p1 PE1 -p2 PE2 -o OUTDIR [-n NUMBER] -p PREFIX

    optional arguments:
      -h, --help            show this help message and exit
      -p1 PE1, --pe1 PE1    5' reads
      -p2 PE2, --pe2 PE2    3' reads
      -o OUTDIR, --outdir OUTDIR
                            output directory
      -n NUMBER, --number NUMBER
                            the number sequence you want
      -p PREFIX, --prefix PREFIX
                            prefix of output


metaphlan.py
=========================
::

    usage: MetaPhlAn2 uses a database of clade-specific marker genes to classify. [-h] -p1 PE1 -p2 PE2 -i INDEX -o OUTDIR -p PREFIX

    optional arguments:
      -h, --help            show this help message and exit
      -p1 PE1, --pe1 PE1    5' reads
      -p2 PE2, --pe2 PE2    3' reads
      -i INDEX, --index INDEX
                            directory contains metaphlan index
      -o OUTDIR, --outdir OUTDIR
                            output directory
      -p PREFIX, --prefix PREFIX
                            prefix of output

kraken2.py
=========================
::

    usage: Classified out option on the miniKraken database, [-h] -p1 PE1 -p2 PE2 -i INDEX -o OUTDIR -p PREFIX

    optional arguments:
      -h, --help            show this help message and exit
      -p1 PE1, --pe1 PE1    5' reads
      -p2 PE2, --pe2 PE2    3' reads
      -i INDEX, --index INDEX
                            directory contains kraken2 index
      -o OUTDIR, --outdir OUTDIR
                            output directory
      -p PREFIX, --prefix PREFIX
                            prefix of output

metaspades.py
=========================
::

    usage: assemble genome using metaSPAdes. [-h] -p1 PE1 -p2 PE2 -o OUTDIR -p PREFIX

    optional arguments:
      -h, --help            show this help message and exit
      -p1 PE1, --pe1 PE1    5' reads
      -p2 PE2, --pe2 PE2    3' reads
      -o OUTDIR, --outdir OUTDIR
                            output directory
      -p PREFIX, --prefix PREFIX
                            prefix of output

CARD.py
=========================
::

    usage:
    Identify resistance genes.
     [-h] -p1 PE1 -p2 PE2 -o OUTDIR -r REFERENCE -p PREFIX

    optional arguments:
      -h, --help            show this help message and exit
      -p1 PE1, --pe1 PE1    5 reads
      -p2 PE2, --pe2 PE2    3 reads
      -o OUTDIR, --outdir OUTDIR
                            output directory
      -r REFERENCE, --reference REFERENCE
                            path database of ResFinder
      -p PREFIX, --prefix PREFIX
                            prefix of output

diamond.py
==============================
::

    usage: Use Diamond mapping the database to classify. [-h] -p1 PE1 -p2 PE2 -o OUTDIR -p PREFIX -d DIAMOND -m MAPPING_FILE

    optional arguments:
      -h, --help            show this help message and exit
      -p1 PE1, --pe1 PE1    5 reads
      -p2 PE2, --pe2 PE2    3 reads
      -o OUTDIR, --outdir OUTDIR
                            output directory
      -p PREFIX, --prefix PREFIX
                            prefix of output
      -d DIAMOND, --diamond DIAMOND
                            diamond database file **.dmnd
      -m MAPPING_FILE, --mapping_file MAPPING_FILE
                            megan6 mapping file.

megahit.py
======================================
::

    usage: MEGAHIT is an ultra-fast and memory-efficient NGS assembler [-h] -p1 PE1 -p2 PE2 -o OUTDIR -p PREFIX

    optional arguments:
      -h, --help            show this help message and exit
      -p1 PE1, --pe1 PE1    R1 fastq file
      -p2 PE2, --pe2 PE2    R2 fastq file
      -o OUTDIR, --outdir OUTDIR
                            output directory
      -p PREFIX, --prefix PREFIX
                            prefix of output