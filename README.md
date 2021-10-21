# Pipeline for the quantification of expression and splicing using Salmon and rMATS 

## Prep

### Step 1 
Trim reads using Trimmomatic using the bellow command
```sh
java -jar trimmomatic.jar PE -phred33 read_1.fastq.gz read_2.fastq.gz read_1_forward_paired.fastq.gz read_1_forward_unpaired.fastq.gz read_2_reverse_paired.fastq.gz read_2_reverse_unpaired.fastq.gz ILLUMINACLIP:adaptors.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:95']
```

Submit multiple scripts using the following bash cheat with for loops to loop over samples, species, etc..
For below to work, reads must in format 

sample_x_reads_1.fastq.gz for forward and sample_x_reads_2.fastq.gz for reverse (sample_x_reads is the variable bit that doesn't matter but **1/2.fastq.gz** must be the same)

If you need to rename the suffix of your reads use the following commands (sub what ever you want)
 
```sh
rename _sequence.txt.gz .fastq.gz *sequence.txt.gz 
```

```sh
#!/bin/bash

# Request one hour of wallclock time
#$ -l h_rt=8:0:0

# Request RAM
#$ -l rmem=5G

# Select threads
#$ -pe smp 4

# Set the working directory
#$ -wd /fastdata/bop20pp/comp_exp_models/wdir/

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
java -jar $trimmomatic PE -phred33 ${r1} ${r2} ${stem}1_forward_paired.fastq.gz ${stem}1_forward_unpaired.fastq.gz ${stem}2_reverse_paired.fastq.gz ${stem}2_reverse_unpaired.fastq.gz ILLUMINACLIP:${adapters}:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:95']

##############################################
```

## SALMON 

### Step 1

## rMATs 
### Step 1 
