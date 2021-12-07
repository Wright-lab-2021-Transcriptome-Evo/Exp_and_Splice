#!/bin/bash

#$ -l h_rt=5:0:0

#$ -l rmem=4G

#$ -pe smp 4

#$ -wd //fastdata/bop20pp/exp_and_splice/nextflow//rmats/wdir

source /usr/local/extras/Genomics/.bashrc

module load libs/lapack/3.4.2-5/binary

module load libs/gsl/2.4/gcc-6.2

module load apps/python/anaconda2-4.2.0

module load libs/blas/3.4.2-5/binary

conda activate rmats

rmats --b1 /fastdata/bop20pp/exp_and_splice/nextflow//rmats/pcr_F_path.txt --b2 /fastdata/bop20pp/exp_and_splice/nextflow//rmats/pcr_M_path.txt --gtf /fastdata/bop20pp/exp_and_splice/nextflow//gtf/pcr.gtf -t paired --readLength 100 --od /fastdata/bop20pp/exp_and_splice/nextflow//rmats
