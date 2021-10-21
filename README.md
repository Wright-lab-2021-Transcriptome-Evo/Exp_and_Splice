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

[see relevant script here: Step_1_trimmomatic.sh](Scripts/Prep/Step_1_trimmomatic.sh)
## SALMON 

### Step 1

## rMATs 
### Step 1 
