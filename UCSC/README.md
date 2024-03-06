[For hg19:http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/latest/ ](http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/latest/)

[For hg38:http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/latest/ ](http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/latest/)

[https://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/ ](https://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/)

### liftover

**UCSC chain files**

    Chain files from hs1 (T2T-CHM13) to hg38/hg19/mm10/mm9 (ore vice versa): https://hgdownload.soe.ucsc.edu/goldenPath/hs1/liftOver/

    Chain files from hg38 (GRCh38) to hg19 and all other organisms: http://hgdownload.soe.ucsc.edu/goldenPath/hg38/liftOver/

    Chain File from hg19 (GRCh37) to hg17/hg18/hg38 and all other organisms: http://hgdownload.soe.ucsc.edu/goldenPath/hg19/liftOver/

**Ensembl chain files**

    Human to Human: http://ftp.ensembl.org/pub/assembly_mapping/homo_sapiens/

**Tools**

[CrossMap:https://crossmap.sourceforge.net/](https://crossmap.sourceforge.net/)

[picard:https://gatk.broadinstitute.org/hc/en-us/articles/360037060932-LiftoverVcf-Picard](https://gatk.broadinstitute.org/hc/en-us/articles/360037060932-LiftoverVcf-Picard)

    java -jar picard.jar LiftoverVcf \\
     I=input.vcf \\
     O=lifted_over.vcf \\
     CHAIN=b37tohg38.chain \\
     REJECT=rejected_variants.vcf \\
     R=reference_sequence.fasta
     其中The reference sequence (fasta) for the TARGET genome build
