# Introduction

This pipeline will take single sample VCF files along with a list of SNP rsIDs and
check if a) all SNPs within the list are present in each VCF file and b) all SNPs 
within the list have passed QC within each VCF file (VCF column FILTER equal to PASS). 
For all VCF files where these two criteria have been met, files will be merged into
one compressed multi-sample VCF. A log file is also output, containing a list
of the VCF samples assessed and their status (PASS or listing if a SNP is missing
or failed). 


# Test Data

You can run a minimal test to check if the pipeline is working properly.
Please note that this pipeline requires Nextflow, which can be installed
by following the [`official documentation`](https://www.nextflow.io/docs/latest/getstarted.html). 

After cloning the data-science repository and navigating to the `variant_checker`
directory:

1. Change the paths stored within `test_data/sample_sheet.csv` to direct the 
pipeline to the absolute location of the sample VCF files within
the `test_data` directory.

3. Run the following command, updating the relevant paths to where the files
are located on your local machine. Note that the directory specified in the
`--output` command needs to be a directory that currently exists.

```
    nextflow run variant_checker.nf \
        --sample_sheet <path/to/test_data/sample_sheet.csv> \
        --output <path/to/output/> \
        --snps <path/to/test_data/list_of_snps.csv> \
        --batch "test_batch"
```

# General Useage

The typical command for running the pipeline is as follows:
```
    nextflow run variant_checker.nf \
        --sample_sheet <path/to/sample_sheet.csv> \
        --output <path/to/output/> \
        --snps <path/to/list_of_snps.csv> \
        --batch "batch_name"
```

Mandatory arguments:
```
      --sample_sheet [file]          Path to CSV file with a list of VCF file paths.
      --output [dir]                 Directory for outputs, must exist. 
      --snps [file]                  Path to TXT file with a list of SNP rsIDs.
      --batch [dir]                  Name of the output multisample VCF (doesn't require file extension)
```

There are no additional options at present.
