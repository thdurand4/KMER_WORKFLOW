import argparse
import gzip
import os
import subprocess

parser = argparse.ArgumentParser(description='Count number of reads and check if this number is not < to sub set number')
parser.add_argument('--input',
                    help='Fastq.gz reads',
                    required=True)
parser.add_argument('--output', help='Output file', required=True)
parser.add_argument('--subset', help='Number of read to subsampling', required=True)

args = parser.parse_args()
fastq = args.input
out = args.output
subset = args.subset
f = open(out,'w')


nb_reads = subprocess.check_output("zcat "+fastq+" | wc -l | awk '{print $1/4}'", shell=True)

if "gz" in fastq:
    if int(nb_reads) >= int(subset):
        print("Reads count", int(nb_reads), "Reads subsampling", int(subset), "Good",file=f)
    else:
        raise ValueError(f"You have not enought count reads in your file", fastq, "Please make sure to have more reads", int(nb_reads), "than subsampling", int(subset))

