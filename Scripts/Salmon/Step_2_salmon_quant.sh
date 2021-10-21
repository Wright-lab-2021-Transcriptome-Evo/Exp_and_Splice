#!/bin/bash

# Request one hour of wallclock time
#$ -l h_rt=8:0:0

# Request RAM
#$ -l rmem=5G

# Select threads
#$ -pe smp 4

# Set the working directory
#$ -wd /fastdata/bop20pp/wdir/exp_and_splice

# Run the application.

echo "started"
date
source /usr/local/extras/Genomics/.bashrc

source activate salmon

stem=${2%*1_forward_paired.fastq.gz}
sam_temp=${stem##*/}
sample=${sam_temp%_}

mkdir /fastdata/bop20pp/exp_and_splice/salmon/${1}/$sample

salmon quant -i /fastdata/bop20pp/cds/${1}_salmon_index -l A -1 ${stem}1_forward_paired.fastq.gz -2 ${stem}2_reverse_paired.fastq.gz --validateMappings -o /fastdata/bop20pp/exp_and_splice/salmon/$1/$sample --gcBias --seqBias
date
