#!/bin/bash -ue
if grep -q 'PASS' sample_4.vcf.gz.check; then
    echo "Sorting and indexing sample_4.vcf.gz"
    bcftools sort sample_4.vcf.gz -Oz -o sample_4.vcf.sorted.vcf.gz
    bcftools index -t sample_4.vcf.sorted.vcf.gz
else
    echo "sample_4.vcf.gz did not pass checks"
    touch sample_4.vcf.gz.sorted.vcf.gz.skip
fi
