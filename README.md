# Pipeline for the quantification of expression and splicing using Salmon and rMATS 

## Salomon

### Step 1 
Trim reads using Trimmomatic 
```sh
java -jar trimmomatic.jar PE -phred33 read_1.fastq.gz read_2.fastq.gz read_1_forward_paired.fastq.gz read_1_forward_unpaired.fastq.gz read_2_reverse_paired.fastq.gz read_2_reverse_unpaired.fastq.gz ILLUMINACLIP:adaptors.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:95']
```

Submit multiple scripts using the following bash cheat
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
r1=$1
#Take stem of name
y1=${r1%*.fastq.gz}

r2=$2
y2=${r2%*.fastq.gz}

adapters=$3

java -jar trimmomatic.jar PE -phred33 read_1.fastq.gz read_2.fastq.gz $y1_forward_paired.fastq.gz $y1_forward_unpaired.fastq.gz $y2_reverse_paired.fastq.gz $y2_reverse_unpaired.fastq.gz ILLUMINACLIP:adaptors.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:95']


```
## rMATs 
### Step 1 
