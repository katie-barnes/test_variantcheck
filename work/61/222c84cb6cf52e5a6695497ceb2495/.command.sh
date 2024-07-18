#!/bin/bash -ue
if grep -q 'PASS' sample_2.vcf.check; then
    echo "Sorting and indexing sample_2.vcf"
   # bcftools sort sample_2.vcf -Oz -o sample_2.vcf.sorted.vcf.gz
   # bcftools index -t sample_2.vcf.sorted.vcf.gz
else
    echo "sample_2.vcf did not pass checks"
    touch sample_2.vcf.sorted.vcf.gz.skip
fi
