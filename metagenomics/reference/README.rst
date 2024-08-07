
metaphlan ::

    #http://cmprod1.cibio.unitn.it/biobakery3/metaphlan_databases/
    mkdir -p reference/metaphlan
    cd reference/metaphlan
    wget http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vJan21_CHOCOPhlAnSGB_202103.tar
    wget http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vJan21_CHOCOPhlAnSGB_202103_marker_info.txt.bz2
    wget http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vJan21_CHOCOPhlAnSGB_202103_species.txt.bz2
    tar xvf mpa_vJan21_CHOCOPhlAnSGB_202103.tar
    bunzip2 *.bz2
    bowtie2-build mpa_vJan21_CHOCOPhlAnSGB_202103_SGB.fna mpa_vJan21_CHOCOPhlAnSGB_202103_SGB

    metaphlan/
    ├── mpa_vJan21_CHOCOPhlAnSGB_202103_SGB.1.bt2
    ├── mpa_vJan21_CHOCOPhlAnSGB_202103_SGB.2.bt2
    ├── mpa_vJan21_CHOCOPhlAnSGB_202103_SGB.3.bt2
    ├── mpa_vJan21_CHOCOPhlAnSGB_202103_SGB.4.bt2
    ├── mpa_vJan21_CHOCOPhlAnSGB_202103_SGB.fna
    ├── mpa_vJan21_CHOCOPhlAnSGB_202103_SGB_marker_info.txt
    ├── mpa_vJan21_CHOCOPhlAnSGB_202103_SGB.pkl
    ├── mpa_vJan21_CHOCOPhlAnSGB_202103_SGB.rev.1.bt2
    └── mpa_vJan21_CHOCOPhlAnSGB_202103_SGB.rev.2.bt2

CARD   ::

    #https://github.com/arpcard/rgi#load-card-reference-data
    mkdir -p reference/CARD
    cd reference/metaphlan
    wget https://card.mcmaster.ca/latest/data
    tar -xvf data card.json
    rgi load --card_json card.json --local
    rgi card_annotation -i card.json
    rgi load -i card.json --card_annotation card_database_v3.0.1.fasta --local
    wget -O wildcard_data.tar.bz2 https://card.mcmaster.ca/latest/variants
    mkdir -p wildcard
    tar -xjf wildcard_data.tar.bz2 -C wildcard
    gunzip wildcard/*.gz
    rgi wildcard_annotation -i wildcard --card_json card.json -v version_number
    rgi load --wildcard_annotation wildcard_database_v3.0.2.fasta --wildcard_index /path/to/wildcard/index-for-model-sequences.txt --card_annotation card_database_v3.0.1.fasta --local

    CARD/
    ├── card.json
    └── localDB
        ├── 61mer_database.json
        ├── amr_61mer.txt
        ├── bwt
        ├── card.json
        ├── card_reference.fasta
        ├── card_wildcard_reference.fasta
        ├── index-for-model-sequences.txt
        └── loaded_databases.json




Kraken2 ::


    Kraken Wiki:https://github.com/DerrickWood/kraken2/wiki
    Kraken index: https://benlangmead.github.io/aws-indexes/k2

    mkdir -p reference/kraken2
    cd reference/kraken2
    wget https://genome-idx.s3.amazonaws.com/kraken/k2_pluspf_16gb_20220908.tar.gz

    kraken2
    ├── database100mers.kmer_distrib
    ├── database150mers.kmer_distrib
    ├── database200mers.kmer_distrib
    ├── database250mers.kmer_distrib
    ├── database300mers.kmer_distrib
    ├── database50mers.kmer_distrib
    ├── database75mers.kmer_distrib
    ├── hash.k2d
    ├── inspect.txt
    ├── opts.k2d
    ├── seqid2taxid.map
    └── taxo.k2d
human_phinx_index(host index) ::

    mkdir -p reference/human_phinx_index/
    # download phinx from NCBI
    https://www.ncbi.nlm.nih.gov/nuccore/NC_001422
    # download human genome sequence from gencode
    wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_41/GRCh38.p13.genome.fa.gz
    cd reference/human_phinx_index/
    cat GRCh38.p13.genome.fa.gz NC_001422.fasta >host.fasta
    bowtie2-build host.fasta host.fasta

    human_phix_index/
    ├── GRCh38.p13.genome.fa
    ├── host.fasta
    ├── host.fasta.1.bt2
    ├── host.fasta.2.bt2
    ├── host.fasta.3.bt2
    ├── host.fasta.4.bt2
    ├── host.fasta.rev.1.bt2
    ├── host.fasta.rev.2.bt2
    └── NC_001422.fasta

adapter ::

    mkdir -p reference/adpater/
    ./
    ├── NexteraPE-PE.fa
    ├── TruSeq2-PE.fa
    ├── TruSeq2-SE.fa
    ├── TruSeq3-PE-2.fa
    ├── TruSeq3-PE.fa
    └── TruSeq3-SE.fa
    Download files from Trimmomatic(http://www.usadellab.org/cms/index.php?page=trimmomatic)

ResFinder ::

    mkdir reference/ResFinder
    cd reference/ResFinder
    git clone https://git@bitbucket.org/genomicepidemiology/resfinder_db.git
    python3 INSTALL.py

    ResFinder/
    └── resfinder_db
        ├── all.comp.b
        ├── all.length.b
        ├── all.name
        ├── all.seq.b
        ├── aminoglycoside.comp.b
        ├── aminoglycoside.fsa
        ├── aminoglycoside.length.b
        ├── aminoglycoside.name
        ├── aminoglycoside.seq.b
        ├── antibiotic_classes.txt
        ├── beta-lactam.comp.b
        ├── beta-lactam.fsa
        ├── beta-lactam.length.b
        ├── beta-lactam.name
        ├── beta-lactam.seq.b
        ├── CHECK-entries.sh
        ├── colistin.comp.b
        ├── colistin.fsa
        ├── colistin.length.b
        ├── colistin.name
        ├── colistin.seq.b
        ├── config
        ├── disinfectant.comp.b
        ├── disinfectant.fsa
        ├── disinfectant.length.b
        ├── disinfectant.name
        ├── disinfectant.seq.b
        ├── fosfomycin.comp.b
        ├── fosfomycin.fsa
        ├── fosfomycin.length.b
        ├── fosfomycin.name
        ├── fosfomycin.seq.b
        ├── fusidicacid.comp.b
        ├── fusidicacid.fsa
        ├── fusidicacid.length.b
        ├── fusidicacid.name
        ├── fusidicacid.seq.b
        ├── glycopeptide.comp.b
        ├── glycopeptide.fsa
        ├── glycopeptide.length.b
        ├── glycopeptide.name
        ├── glycopeptide.seq.b
        ├── history.txt
        ├── INSTALL.py
        ├── macrolide.comp.b
        ├── macrolide.fsa
        ├── macrolide.length.b
        ├── macrolide.name
        ├── macrolide.seq.b
        ├── nitroimidazole.comp.b
        ├── nitroimidazole.fsa
        ├── nitroimidazole.length.b
        ├── nitroimidazole.name
        ├── nitroimidazole.seq.b
        ├── notes.txt
        ├── oxazolidinone.comp.b
        ├── oxazolidinone.fsa
        ├── oxazolidinone.length.b
        ├── oxazolidinone.name
        ├── oxazolidinone.seq.b
        ├── phenicol.comp.b
        ├── phenicol.fsa
        ├── phenicol.length.b
        ├── phenicol.name
        ├── phenicol.seq.b
        ├── phenotype_panels.txt
        ├── phenotypes.txt
        ├── pseudomonicacid.comp.b
        ├── pseudomonicacid.fsa
        ├── pseudomonicacid.length.b
        ├── pseudomonicacid.name
        ├── pseudomonicacid.seq.b
        ├── quinolone.comp.b
        ├── quinolone.fsa
        ├── quinolone.length.b
        ├── quinolone.name
        ├── quinolone.seq.b
        ├── README.md
        ├── rifampicin.comp.b
        ├── rifampicin.fsa
        ├── rifampicin.length.b
        ├── rifampicin.name
        ├── rifampicin.seq.b
        ├── sulphonamide.comp.b
        ├── sulphonamide.fsa
        ├── sulphonamide.length.b
        ├── sulphonamide.name
        ├── sulphonamide.seq.b
        ├── tetracycline.comp.b
        ├── tetracycline.fsa
        ├── tetracycline.length.b
        ├── tetracycline.name
        ├── tetracycline.seq.b
        ├── trimethoprim.comp.b
        ├── trimethoprim.fsa
        ├── trimethoprim.length.b
        ├── trimethoprim.name
        └── trimethoprim.seq.b

diamond ::

    mkdir reference/diamond
    wget https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz
    gunzip nr.gz
    diamond makedb --in nr -d nr

    diamond/
    ├── nr
    └── nr.dmnd

megan6 ::

    https://software-ab.informatik.uni-tuebingen.de/download/megan6/welcome.html
    # download mapping file:
    mkdir reference/MEGAN
    wget https://software-ab.informatik.uni-tuebingen.de/download/megan6/megan-map-Feb2022.db.zip
    gunzip megan-map-Feb2022.db.zip

    MEGAN/
    ├── megan-map-Feb2022.db
    └── megan-map-Feb2022.db.zip

VFDB ::

    mkdir reference/VFDB
    wget http://www.mgc.ac.cn/VFs/Down/VFDB_setB_nt.fas.gz
    wget http://www.mgc.ac.cn/VFs/Down/VFDB_setB_pro.fas.gz
    makeblastdb -in VFDB_setB_nt.fas -dbtype nucl -out VFDB_setB_nt.fas
    makeblastdb -in VFDB_setB_pro.fas -dbtype prot -out VFDB_setB_pro.fas

    VFDB/
    ├── VFDB_setB_nt.fas
    ├── VFDB_setB_nt.fas.nhr
    ├── VFDB_setB_nt.fas.nin
    ├── VFDB_setB_nt.fas.nsq
    ├── VFDB_setB_pro.fas
    ├── VFDB_setB_pro.fas.phr
    ├── VFDB_setB_pro.fas.pin
    └── VFDB_setB_pro.fas.psq

taxonomy ::

    mkdir -p /reference/taxonomy/accession2taxid
    cd /reference/taxonomy/accession2taxid
    wget https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
    wget https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_wgs.accession2taxid.gz
    wget https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.gz
    wget https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/dead_wgs.accession2taxid.gz
    wget https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/dead_prot.accession2taxid.gz
    wget https://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/dead_nucl.accession2taxid.gz
    /software/KronaTools-2.8.1/updateAccessions.sh --only-build /reference/taxonomy/
    wget https://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
    /software/KronaTools-2.8.1/updateTaxonomy.sh --only-build /reference/taxonomy/

