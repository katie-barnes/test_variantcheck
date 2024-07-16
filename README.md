################################################################################
#                                                                              #
#                          SNP CHECK SCRIPT                                    #
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