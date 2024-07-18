#!/bin/bash -ue
echo "Checking SNPs in sample_2.vcf"
python3 /Users/katiebarnes/Desktop/test_variantcheck/check_snps.py sample_2.vcf snps.txt > sample_2.vcf.check
cat sample_2.vcf.check
