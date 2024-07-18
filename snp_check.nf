#!/usr/bin/env nextflow

nextflow.enable.dsl=2

workflow {
    // Read the CSV file and create a channel with paths to VCF files
    vcf_files = Channel
        .fromPath(params.sample_sheet)
        .splitCsv(header: false, sep: ',')
        .map { row -> file(row[0], checkIfExists: true) }

    // Run checkSNPs for each VCF file
    snp_check = checkSNPs(vcf_files, file(params.snps))

    // Run sortIndexVCFs for each checked VCF file
    sorted_vcfs = sortIndexVCFs(snp_check)

    test = sorted_vcfs.collect()
    test.view()

    // Merge the sorted VCF files
    merged_vcf = mergeVCFs(sorted_vcfs.collect())
}

process checkSNPs {
    input:
    path vcf_file
    file snps_file

    output:
    tuple path(vcf_file), file("${vcf_file}.check")

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
        echo "Sorting and indexing ${vcf_file}"
        bcftools sort ${vcf_file} -Oz -o ${vcf_file.baseName}.sorted.vcf.gz
        bcftools index -t ${vcf_file.baseName}.sorted.vcf.gz
    else
        echo "${vcf_file} did not pass checks"
        touch ${vcf_file.baseName}.sorted.vcf.gz
        touch ${vcf_file.baseName}.sorted.vcf.gz.tbi
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
    bcftools merge ${sorted_vcfs.join(' ')} -Oz -o merged.vcf.gz
    """
}