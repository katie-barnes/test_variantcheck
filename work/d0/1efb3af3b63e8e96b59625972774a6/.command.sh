#!/bin/bash -ue
if grep -q 'PASS' sample_2.vcf.check; then
    bcftools sort sample_2.vcf -Oz -o sample_2.sorted.vcf.gz
    bcftools index -t sample_2.sorted.vcf.gz
else
    touch sample_2.sorted.vcf.gz
fi
