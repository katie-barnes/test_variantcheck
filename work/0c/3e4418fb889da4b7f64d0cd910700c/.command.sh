#!/bin/bash -ue
if grep -q 'PASS' sample_4.vcf.gz.check; then
    bcftools sort sample_4.vcf.gz -Oz -o sample_4.vcf.sorted.vcf.gz
    bcftools index -t sample_4.vcf.sorted.vcf.gz
else
    touch sample_4.vcf.sorted.vcf.gz
fi
