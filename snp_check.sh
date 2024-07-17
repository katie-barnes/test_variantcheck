#!/bin/bash

################################################################################
#                                                                              #
#                      Variant checker                                         #
#                                                                              #
# This script processes one or multiple VCF files to check the presence and    #
# quality of specified SNPs. The results are written to a single text file     #
# containing all samples with each SNP as a row and each sample as a column.   #
#                                                                              #
# Usage:                                                                       #
#   ./snp_check.sh <input1.vcf> [input2.vcf] [...] [-o output_directory] [-b batch_name] #
#                                                                              #
# Example:                                                                     #
#   ./snp_check.sh sample1.vcf sample2.vcf -o mydirectory -b mybatch           #
#   ./snp_check.sh *.vcf -o mydirectory                                        #
#   ./snp_check.sh sample1.vcf                                                 #
#                                                                              #
################################################################################

set -e
trap 'echo "An error occurred. Exiting..." >&2; exit 1' ERR

LOG_FILE="snp_check.log"
exec > >(tee -i "$LOG_FILE") 2>&1

# Default values
output_dir="."
batch_name="batch"

# Parse command line arguments
vcf_files=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -o)
      output_dir="$2"
      shift
      shift
      ;;
    -b)
      batch_name="$2"
      shift
      shift
      ;;
    *)
      vcf_files+=("$1")
      shift
      ;;
  esac
done

# Check if at least one VCF file was provided
if [ ${#vcf_files[@]} -lt 1 ]; then
  echo "Usage: $0 <input1.vcf> [input2.vcf] [...] [-o output_directory] [-b batch_name]"
  exit 1
fi

# Array of SNPs to check
declare -a snps=(
  "rs34805604" 
  "rs33939927" 
  "rs34995376" 
  "rs35801418" 
  "rs34637584" 
  "rs35870237" 
  "rs34778348"
)

# Initialize summary file with header
summary_file="${output_dir}/${batch_name}_summary.txt"
header="SNP"
for vcf_file in "${vcf_files[@]}"; do
  sample_name=$(basename "$vcf_file" .vcf)
  sample_name=$(basename "$sample_name" .vcf.gz)
  header+="\t$sample_name"
done
echo -e "$header" > "$summary_file"

# Loop through each SNP
for snp in "${snps[@]}"; do
  # Initialize the row with the SNP name
  row="$snp"

  # Loop through each VCF file provided as an argument
  for vcf_file in "${vcf_files[@]}"; do
    if [[ "$vcf_file" == *.vcf.gz ]]; then
      # Use zgrep to find the SNP in the gzipped VCF file
      snp_present=$(zgrep -w "$snp" "$vcf_file" || true)
    else
      # Use grep to find the SNP in the VCF file
      snp_present=$(grep -w "$snp" "$vcf_file" || true)
    fi
    
    if [ -n "$snp_present" ]; then
      # Check if the FILTER field is PASS
      snp_pass=$(echo "$snp_present" | grep -w "PASS" || true)
      
      if [ -n "$snp_pass" ]; then
        row+="\tY/Y"
      else
        row+="\tY/X"
      fi
    else
      row+="\tX/X"
    fi
  done

  # Append the row to the summary file
  echo -e "$row" >> "$summary_file"
done

# Array to hold the names of files that pass the criteria
declare -a valid_vcfs=()

# Loop through each VCF file provided as an argument again for sorting and indexing
for vcf_file in "${vcf_files[@]}"; do
  # Extract the base name of the input file (without extension)
  base_name=$(basename "$vcf_file" .vcf)
  base_name=$(basename "$base_name" .vcf.gz)

  # Initialize flags
  missing_variant_flag=0
  failed_qc_flag=0

  # Check if the file is valid (i.e., contains all SNPs and passes QC)
  valid_file=true

  for snp in "${snps[@]}"; do
    if [[ "$vcf_file" == *.vcf.gz ]]; then
      snp_present=$(zgrep -w "$snp" "$vcf_file" || true)
    else
      snp_present=$(grep -w "$snp" "$vcf_file" || true)
    fi

    if [ -z "$snp_present" ]; then
      missing_variant_flag=1
      valid_file=false
    elif ! echo "$snp_present" | grep -q "PASS"; then
      failed_qc_flag=1
      valid_file=false
    fi
  done

  # Display appropriate messages
  if [ $missing_variant_flag -eq 1 ]; then
    echo "WARNING: ${base_name} has at least one missing variant"
  fi
  if [ $failed_qc_flag -eq 1 ]; then
    echo "WARNING: ${base_name} has at least one QC-failed variant"
  fi

  if [ "$valid_file" = true ]; then
    valid_vcfs+=("$vcf_file")
  fi
done

# If there are valid VCF files, sort, index, and merge them
if [ ${#valid_vcfs[@]} -gt 0 ]; then
  sorted_vcfs=()

  for vcf_file in "${valid_vcfs[@]}"; do
    # Sort the VCF file
    sorted_file="${vcf_file%.vcf*}.sorted.vcf.gz"
    bcftools sort "$vcf_file" -Oz -o "$sorted_file"
    
    # Index the sorted VCF file
    bcftools index -t "$sorted_file"
    
    # Add the sorted file to the list
    sorted_vcfs+=("$sorted_file")
  done

  # Merge the sorted VCF files
  merged_file="${output_dir}/${batch_name}.vcf.gz"
  bcftools merge "${sorted_vcfs[@]}" -Oz -o "$merged_file"
  
  echo "Merged VCF file created at $merged_file"

  # Remove sorted files
  for sorted_file in "${sorted_vcfs[@]}"; do
    rm -f "$sorted_file" "${sorted_file}.tbi"
  done
else
  echo "No VCF files passed the SNP check criteria."
fi