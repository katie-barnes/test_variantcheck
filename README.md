# Neuron23 variant checker                               

This script processes one or more VCF files to check the presence and quality of specified SNPs. The results are written to text files with the suffix "*_snpcheck.txt". If a directory is specified as the last argument, the results will be written to that directory. Otherwise, the results will be written to the current directory.

Input:
- One or more VCF files

Output:
- A text file per VCF file listing each variant queried and if it was
present within the VCF file and if it was listed as PASS under the VCF FILTER
column. For example:

```
# sample_1
SNP	PRESENT_IN_VCF	QC_PASS
rs34805604	PRESENT	PASS
rs33939927	PRESENT	FAIL
rs34995376	PRESENT	PASS
rs35801418	PRESENT	PASS
rs34637584	PRESENT	PASS
rs35870237	MISSING	-
rs34778348	PRESENT	PASS
```

Usage:                                                                       
```
./neuron23_snp_check.sh <input1.vcf> [input2.vcf] [...] [output_directory]
```

Example useages:
```
./neuron23_snp_check.sh sample1.vcf sample2.vcf mydirectory                
./neuron23_snp_check.sh *.vcf mydirectory                                  
./neuron23_snp_check.sh sample1.vcf                                        
```                                                             

To try with the test data, clone this folder and run:
```
./neuron23_snp_check.sh test_data/*.vcf           
```






