import sys
import gzip

vcf_file = sys.argv[1]
snps_file = sys.argv[2]

# Read the list of SNPs
with open(snps_file, 'r') as f:
    snps = set(line.strip() for line in f)

def read_vcf(vcf_file):
    if vcf_file.endswith('.gz'):
        with gzip.open(vcf_file, 'rt') as f:
            return [line.strip() for line in f if not line.startswith('#')]
    else:
        with open(vcf_file, 'r') as f:
            return [line.strip() for line in f if not line.startswith('#')]

vcf_data = read_vcf(vcf_file)

# Check each SNP
missing_snps = []
failed_snps = []

for snp in snps:
    found = False
    for line in vcf_data:
        if snp in line:
            found = True
            if 'PASS' not in line.split('\t')[6]:
                failed_snps.append(snp)
            break
    if not found:
        missing_snps.append(snp)

# Output results
if missing_snps:
    for snp in missing_snps:
        print(f"{vcf_file}: {snp} is not present")

if failed_snps:
    for snp in failed_snps:
        print(f"{vcf_file}: {snp} has failed QC")

if not missing_snps and not failed_snps:
    print(f"{vcf_file}: PASS")