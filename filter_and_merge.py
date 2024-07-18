import os
import sys

def main(vcf_files, output_file):
    non_empty_vcfs = [vcf for vcf in vcf_files if os.path.getsize(vcf) > 0]

    if not non_empty_vcfs:
        print("No non-empty VCF files to merge")
        open(output_file, "a").close()
    else:
        os.system("bcftools merge " + " ".join(non_empty_vcfs) + " -Oz -o " + output_file)

if __name__ == "__main__":
    vcf_files = sys.argv[1:-1]
    output_file = sys.argv[-1]
    main(vcf_files, output_file)