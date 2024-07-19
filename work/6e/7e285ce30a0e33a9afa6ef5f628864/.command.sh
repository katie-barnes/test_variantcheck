#!/bin/bash -ue
if grep -q 'PASS' sample_3.vcf.check; then
    echo "Sorting and indexing sample_3.vcf"
    bcftools sort sample_3.vcf -Oz -o sample_3.sorted.vcf.gz
    bcftools index -t sample_3.sorted.vcf.gz
else
    echo "sample_3.vcf did not pass checks"
    touch sample_3.sorted.vcf.gz
fi
