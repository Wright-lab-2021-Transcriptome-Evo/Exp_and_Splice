#!/bin/bash

# Request one hour of wallclock time
#$ -l h_rt=1:0:0

# Request RAM
#$ -l rmem=8G

# Select threads
#$ -pe smp 1

# Set the working directory
#$ -wd /fastdata/bop20pp/exp_and_splice/wdir

# Run the application.
# Option 2 are the location of the adapter sequences 


echo "started"
date
source /usr/local/extras/Genomics/.bashrc
module load apps/R

Rscript $1 $2 $3 $4 $5 $6 $7 $8 $9

echo "finished"
date

