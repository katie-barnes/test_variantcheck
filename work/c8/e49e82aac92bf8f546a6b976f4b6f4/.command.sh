#!/bin/bash -ue
if grep -q 'PASS' sample_1.vcf.check; then
    bcftools sort sample_1.vcf -Oz -o sample_1.sorted.vcf.gz
    bcftools index -t sample_1.sorted.vcf.gz
else
    touch sample_1.sorted.vcf.gz
fi
