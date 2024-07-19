#!/usr/bin/env nextflow

nextflow.enable.dsl=2

workflow {
    // Read the CSV file and create a channel with paths to VCF files
    vcf_files = Channel
        .fromPath(params.sample_sheet)
        .splitCsv(header: false, sep: ',')
        .map { row -> file(row[0], checkIfExists: true) }

    // Check if SNPs are present and passing QC in each VCF file
    snp_check = checkSNPs(vcf_files, file(params.snps))

    // If SNPs are present and have passed QC, sort and index VCFs for merging 
    sorted_vcfs = sortIndexVCFs(snp_check)

    // Merge the sorted and indexed VCF files
    merged_vcf = mergeVCFs(sorted_vcfs.collect())
}

process checkSNPs {
    input:
    path vcf_file
    file snps_file

    output:
    tuple path(vcf_file), file("${vcf_file}.check")

    publishDir "${params.output}", mode: 'copy'

    script:
    """
    echo "Checking SNPs in ${vcf_file}"
    python3 /Users/katiebarnes/Desktop/test_variantcheck/check_snps.py ${vcf_file} ${snps_file} > ${vcf_file}.check
    cat ${vcf_file}.check
    """
}

process sortIndexVCFs {
    input:
    tuple path(vcf_file), file(check_file)

    output:
    file("${vcf_file.baseName}.sorted.vcf.gz")

    script:
    """
    if grep -q 'PASS' ${check_file}; then
        bcftools sort ${vcf_file} -Oz -o ${vcf_file.baseName}.sorted.vcf.gz
        bcftools index -t ${vcf_file.baseName}.sorted.vcf.gz
    else
        touch ${vcf_file.baseName}.sorted.vcf.gz
    fi
    """
}

process mergeVCFs {
    input:
    val sorted_vcfs

    output:
    file("merged.vcf.gz")

    publishDir "${params.output}", mode: 'copy'

    script:
    """
    python3 /Users/katiebarnes/Desktop/test_variantcheck/filter_and_merge.py ${sorted_vcfs.join(" ")} merged.vcf.gz
    """
}