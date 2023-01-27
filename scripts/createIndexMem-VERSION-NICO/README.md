# PICTURES pipeline_index

pipeline_index run on SGE clusters, take one or thousand fasta files
Count and sort kmers with jellyfish.

TODO : tell what this bash script do !

when all yours files are well formated you can install and launch createIndex.c

## Dependencies
In order to run PICTURES you need a 64 bit linux operating system.
PICTURES depends on two libraries whitch are SDSL-lite and Zlib. 

Install sdsl : https://github.com/simongog/sdsl-lite
Install zlib : (debian : sudo apt-get install zlib1g-dev)

## Installation

The library compiles with GNU GCC and G++ . It successfully compiles and runs on Xubuntu 16.04 and 17.04.

1. Clone this repository : `git clone git@montreuillois.cirad.fr:ALICIA/PICTURES.git`
2. Compile createIndex : `cd PICTURES && make`
3. Place the createIndex binary somewhere acessible in your `$PATH`

## Example
**Counting and sorting 24-mer with Jellyfish**
Install JellyFish if you want : http://www.genome.umd.edu/jellyfish.html

```
jellyfish count -m 24 -s 500M -o sample.jf <(zcat sample.fastq.gz)
jellyfish dump  -c sample.jf | sort -k 1 > counts.tsv
```

**Create index from the tsv with createIndex**

```
createIndex counts.tsv
```
