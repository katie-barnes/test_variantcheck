#!/bin/bash

################################################################################
#                                                                              #
#                      Neuron23 variant checker                                #
#                                                                              #
# This script processes one or multiple VCF files to check the presence and    #
# quality of specified SNPs. The results are written to text files with the    #
# suffix "_snpcheck.txt". If a directory is specified as the last argument,    #
# the results will be written to that directory. Otherwise, the results will   #
# be written to the current directory.                                         #
#                                                                              #
# Usage:                                                                       #
#   ./neuron23_snp_check.sh <input1.vcf> [input2.vcf] [...] [output_directory] #
#                                                                              #
# Example:                                                                     #
#   ./neuron23_snp_check.sh sample1.vcf sample2.vcf mydirectory                #
#   ./neuron23_snp_check.sh *.vcf mydirectory                                  #
#   ./neuron23_snp_check.sh sample1.vcf                                        #
#                                                                              #
################################################################################

# Check if at least one VCF file was provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <input1.vcf> [input2.vcf] [...] [output_directory]"
  exit 1
fi

# Check if the last argument is a directory
last_arg=${!#}
if [ -d "$last_arg" ]; then
  output_dir=$last_arg
  # Remove the last argument from the list of VCF files
  set -- "${@:1:$(($#-1))}"
else
  output_dir="."
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

# Loop through each VCF file provided as an argument
for vcf_file in "$@"; do
  # Extract the base name of the input file (without extension)
  base_name=$(basename "$vcf_file" .vcf)

  # Define the output file name
  output_file="${output_dir}/${base_name}_snpcheck.txt"

  # Write the base name and header to the output file
  echo -e "# ${base_name}\nSNP\tPRESENT_IN_VCF\tQC_PASS" > "$output_file"

  # Initialize flags
  missing_variant_flag=0
  failed_qc_flag=0

  # Check each SNP
  for snp in "${snps[@]}"; do
    # Use grep to find the SNP in the VCF file
    snp_present=$(grep -w "$snp" "$vcf_file")
    
    if [ -n "$snp_present" ]; then
      # Check if the FILTER field is PASS
      snp_pass=$(echo "$snp_present" | grep -w "PASS")
      
      if [ -n "$snp_pass" ]; then
        echo -e "$snp\tPRESENT\tPASS" >> "$output_file"
      else
        echo -e "$snp\tPRESENT\tFAIL" >> "$output_file"
        failed_qc_flag=1
      fi
    else
      echo -e "$snp\tMISSING\t-" >> "$output_file"
      missing_variant_flag=1
    fi
  done

  echo -e "\n${base_name}: Results have been written to $output_file"

  # Display appropriate messages
  if [ $missing_variant_flag -eq 1 ]; then
    echo "WARNING: ${base_name} has at least one missing variant"
  fi
  if [ $failed_qc_flag -eq 1 ]; then
    echo "WARNING: ${base_name} has at least one QC-failed variant"
  fi

done