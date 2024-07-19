#!/bin/bash -ue
if grep -q 'PASS' sample_5.vcf.check; then
    bcftools sort sample_5.vcf -Oz -o sample_5.sorted.vcf.gz
    bcftools index -t sample_5.sorted.vcf.gz
else
    touch sample_5.sorted.vcf.gz
fi
