#!/bin/bash -ue
echo "Checking SNPs in sample_5.vcf"
python check_snps.py sample_5.vcf snps.txt > sample_5.vcf.check
cat sample_5.vcf.check
