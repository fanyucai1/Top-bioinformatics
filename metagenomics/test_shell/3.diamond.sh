python3 /staging4/fanyucai/metagenomics/script/diamond.py \
-p1 /staging4/fanyucai/metagenomics/test_data/resfinder_test/test_isolate_01_1.fq \
-p2 /staging4/fanyucai/metagenomics/test_data/resfinder_test/test_isolate_01_2.fq \
-o /staging4/fanyucai/metagenomics/output/diamond/ \
-p test -d /staging4/fanyucai/metagenomics/reference/diamond/nr.dmnd \
-m /staging4/fanyucai/metagenomics/reference/MEGAN/megan-map-Feb2022.db
