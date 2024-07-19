#!/bin/bash -ue
if grep -q 'PASS' sample_3.vcf.check; then
    bcftools sort sample_3.vcf -Oz -o sample_3.sorted.vcf.gz
    bcftools index -t sample_3.sorted.vcf.gz
else
    touch sample_3.sorted.vcf.gz
fi
