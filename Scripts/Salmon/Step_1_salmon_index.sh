### THE FIRST AND ONLY INPUT IS THE CDS FILE THAT YOU'RE GOING TO USE WITH YOUR SAMPLES IN SALMON ----

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

out=${1%*.cds.fa}_salmon_index
salmon index -t $1 -i $out
date
