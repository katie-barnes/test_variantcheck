#!/bin/bash -ue
echo "Checking SNPs in sample_1.vcf"
python3 check_snps.py sample_1.vcf snps.txt > sample_1.vcf.check
cat sample_1.vcf.check
