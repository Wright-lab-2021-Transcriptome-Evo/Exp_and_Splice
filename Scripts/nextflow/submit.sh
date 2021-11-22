#!/bin/bash

# Request one hour of wallclock time
#$ -l h_rt=8:0:0

# Request RAM
#$ -l rmem=1G

# Select threads
#$ -pe smp 1

# Set the working directory
#$ -wd /fastdata/bop20pp/exp_and_splice/nextflow

# Run the application.
# Option 2 are the location of the adapter sequences 


echo "started"
date
source /usr/local/extras/Genomics/.bashrc

echo $1
cd /fastdata/bop20pp/exp_and_splice/nextflow
bash commands.bash

echo "finished"
date

