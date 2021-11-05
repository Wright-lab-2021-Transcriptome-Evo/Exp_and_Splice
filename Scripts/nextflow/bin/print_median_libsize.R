#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
data=read.csv(args[1], sep = " ", header = FALSE)
species = args[2]
#species="duck"
#data=read.csv("transform_data.csv", sep = " ", header=F)
print(data[,2][data[,1] == species])


