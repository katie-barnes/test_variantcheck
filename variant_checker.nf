#!/usr/bin/env nextflow
/*
================================================================================
  variant_checker
================================================================================
  Nextflow base pipeline to check for the presence / passing on SNPs in a VCF.
--------------------------------------------------------------------------------
*/

nextflow.enable.dsl=2

////////////////////////////////////////////////////
/* --             HELP MESSAGE                 -- */
////////////////////////////////////////////////////

def helpMessage() {
	println(
    """
    =========================================
    Sano variant_checker pipeline:
    VCF file -> Check SNPs -> Merge ✔️ VCFs
    =========================================

    Usage:
    The typical command for running the pipeline is as follows:

    nextflow run variant_checker.nf \
        --sample_sheet <path/to/sample_sheet.csv> \
        --output <path/to/output/> \
        --snps <path/to/list_of_snps.csv> \
        --batch "batch_name"

    Mandatory arguments:
      --sample_sheet [file]          Path to CSV file with a list of VCF file paths.
      --output [dir]                 Directory for outputs, must exist. 
      --snps [file]                  Path to TXT file with a list of SNP rsIDs.
      --batch [dir]                  Name of the output multisample VCF (doesn't require file extension)

    Additional options:
      <No additional options at present>

    """
    )
}

params.help = false
if (params.help){
    helpMessage()
    System.exit(0)
}


////////////////////////////////////////////////////
/* --          VALIDATE INPUTS                 -- */
////////////////////////////////////////////////////

// Input CSV file and output directory must exist
if (params.sample_sheet) { 
    file(params.sample_sheet, checkIfExists: true) 
} else { 
    exit 1, 'Sample sheet not specified! For help, run command: nextflow run variant_checker.nf --help' 
}

if (file(params.output, checkIfExists: true, type: 'dir')) {  
} else { 
	exit 1, 'Output directory not specified! For help, run command: nextflow run variant_checker.nf --help' 
}

if (params.snps) { 
    file(params.snps, checkIfExists: true) 
} else { 
    exit 1, 'List of SNPs not specified! For help, run command: nextflow run variant_checker.nf --help' 
}


////////////////////////////////////////////////////
/* --               WORKFLOW                   -- */
////////////////////////////////////////////////////

project_dir = projectDir

workflow {
    // Read the CSV file and create a channel with paths to VCF files
    vcf_files = Channel
        .fromPath(params.sample_sheet)
        .splitCsv(header: false, sep: ',')
        .map { row -> file(row[0], checkIfExists: true) }

    // Check if SNPs are present and passing QC in each VCF file
    snp_check = checkSNPs(vcf_files, file(params.snps))

    combineLogs(snp_check.pass_logs.collect())

    // If SNPs are present and have passed QC, sort and index VCFs for merging 
    sorted_vcfs = sortIndexVCFs(snp_check.vcf_files)

    // Merge the sorted and indexed VCF files
    merged_vcf = mergeVCFs(sorted_vcfs.collect())
}


////////////////////////////////////////////////////
/* --               PROCESSES                  -- */
////////////////////////////////////////////////////

process checkSNPs {
    input:
    path vcf_file
    file snps_file

    output:
    tuple path(vcf_file), file("${vcf_file}.check"), emit: vcf_files
    path("${vcf_file}.check"), emit: pass_logs

    script:
    """
    python3 $project_dir/check_snps.py \
        ${vcf_file} \
        ${snps_file} \
        > ${vcf_file}.check
    """
}

process combineLogs {
    input:
    path check_logs

    output:
    file("${params.batch_name}.log")

    publishDir "${params.output}", mode: 'copy'

    script:
    """
    cat ${check_logs.join(' ')} | sort > ${params.batch_name}.log
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
    file("${params.batch_name}.vcf.gz")

    publishDir "${params.output}", mode: 'copy'

    script:
    """
    python3 $project_dir/merge_vcfs.py \
        ${sorted_vcfs.sort().join(" ")} \
        ${params.batch_name}.vcf.gz
    """
}

////////////////////////////////////////////////////
/* --        END OF NEXTFLOW SCRIPT            -- */
////////////////////////////////////////////////////
