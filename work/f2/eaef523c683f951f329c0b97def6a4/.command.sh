#!/bin/bash -ue
echo "Checking SNPs in sample_4.vcf.gz"
python3 check_snps.py sample_4.vcf.gz snps.txt > sample_4.vcf.gz.check
cat sample_4.vcf.gz.check
