#!/bin/bash -ue
if grep -q 'PASS' sample_1.vcf.check; then
    echo "Sorting and indexing sample_1.vcf"
    bcftools sort sample_1.vcf -Oz -o sample_1.sorted.vcf.gz
    bcftools index -t sample_1.sorted.vcf.gz
else
    echo "sample_1.vcf did not pass checks"
    touch sample_1.vcf.sorted.vcf.gz.skip
fi
