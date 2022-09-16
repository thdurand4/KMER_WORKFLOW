#!/bin/sh
### Job name
#SBATCH --job-name=KMER_WORKFLOW

### Requirements
#SBATCH --partition=agap_normal




### Output
#SBATCH --output=/home/garsmeuro/scratch/WORKFLOW_KMER/log_kmer.out
#SBATCH --error=/home/garsmeuro/scratch/WORKFLOW_KMER/log_kmer.err
module purge
module load snakemake


snakemake --use-envmodules -j 200 --cluster-config cluster_config_SLURM.yaml --cluster "sbatch -A agap -p {cluster.partition} -o {cluster.log} -e {cluster.error} -c {cluster.cpus-per-task} --mem-per-cpu {cluster.mem-per-cpu}"
