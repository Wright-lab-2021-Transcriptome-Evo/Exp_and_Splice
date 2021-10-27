#!/bin/bash
#source /usr/local/extras/Genomics/.bashrc
source activate salmon
salmon index -t goose.cds.fa.gz -i goose_index
