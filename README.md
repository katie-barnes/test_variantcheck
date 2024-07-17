# Variant checker                               

This script processes one or more VCF files to check the presence and quality of specified SNPs. The results are written to a text file and VCF files containing all specified SNPs that have PASS within the VCF FILTER column are merged to a multisample VCF. If a directory is specified, the results will be written to that directory. Otherwise, the results will be written to the current directory. The name of the merged multisample VCF is specified using the -b flag.

Input:
One or more .vcf or .vcf.gz files

Arguments:
-o: Output directory, must exist
-b: Batch name, will determine name of multisample VCF and output text file

Output:
- A multisample VCF containing all samples for which the specified SNPs are present
and of sufficient quality (FILTER column equal to PASS).
- A text file with each variant queried as a row and each sample as a column. Each
entry is either Y/Y (SNP present and QC PASS), Y/X (SNP present but not passed QC)
or X/X (SNP missing). For example:

```
SNP	sample_1	sample_2	sample_3	sample_4	sample_5
rs34805604	Y/Y	Y/Y	Y/Y	Y/Y	Y/Y
rs33939927	Y/Y	Y/X	Y/Y	Y/Y	Y/Y
rs34995376	Y/Y	Y/Y	X/X	Y/Y	Y/Y
rs35801418	Y/Y	Y/Y	Y/Y	Y/Y	Y/Y
rs34637584	Y/Y	Y/Y	Y/Y	Y/Y	Y/Y
rs35870237	Y/Y	X/X	Y/Y	Y/X	Y/Y
rs34778348	Y/Y	Y/Y	Y/Y	Y/X	Y/Y
```

Usage:                                                                       
```
./snp_check.sh <input1.vcf> [input2.vcf] [...] [-o output_directory] [-b batch_name]
```

Example useages:
```
./snp_check.sh sample1.vcf sample2.vcf.gz -o mydirectory -b batch_1   
./snp_check.sh *.vcf -b batch_X                                  
./snp_check.sh sample1.vcf                                        
```                                                             

To try with the test data, clone this folder and run:
```
mkdir output
./snp_check.sh test_data/* -o output -b test_batch 
```






