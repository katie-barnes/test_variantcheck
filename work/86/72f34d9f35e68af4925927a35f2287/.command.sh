#!/bin/bash -ue
if grep -q 'PASS' sample_5.vcf.check; then
    echo "Sorting and indexing sample_5.vcf"
    bcftools sort sample_5.vcf -Oz -o sample_5.vcf.sorted.vcf.gz
    bcftools index -t sample_5.vcf.sorted.vcf.gz
else
    echo "sample_5.vcf did not pass checks"
    touch sample_5.vcf.sorted.vcf.gz.skip
fi
