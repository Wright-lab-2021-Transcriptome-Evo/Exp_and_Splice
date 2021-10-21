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
# Option 2 are the location of the adapter sequences


echo "started"
date
source /usr/local/extras/Genomics/.bashrc
trimmomatic=$1 #Location of java based
trimmomatic executable

sample=$2
stem=${sample%*1.fastq.gz}
r1=${stem}1.fastq.gz #Forward reads
#Take stem of name
r2=${stem}2.fastq.gz #Forward reads


adapters=$3 #Location of adapter sequences



### RUN COMMAND ---
java -jar $trimmomatic PE -phred33 ${r1} ${r2} ${stem}1_forward_paired.fastq.gz ${stem}1_forward_unpaired.fastq.gz ${stem}2_reverse_paired.fastq.gz ${stem}2_reverse_unpaired.fastq.gz ILLUMINACLIP:${adapters}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:95

#####################
