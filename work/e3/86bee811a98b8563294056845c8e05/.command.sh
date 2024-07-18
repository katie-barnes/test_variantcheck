#!/bin/bash -ue
echo "Checking SNPs in sample_3.vcf"
python3 check_snps.py sample_3.vcf snps.txt > sample_3.vcf.check
cat sample_3.vcf.check
