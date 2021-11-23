#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

library(plotrix)
library(phytools)
library(OUwie)
library(evemodel)
library(dplyr)


tree <- read.nexus(args[1])
exp_data <- read.csv(args[2], row.names = 1)
metadata <- read.csv(args[3], header = F) 

colnames(metadata) <- c("code", 'species', 'sex', 'tissue', 'sample', 'ensembl_datasets')
s = args[4]
t = args[5]
out = args[6]


metadata = filter(metadata, sex == s & tissue == t)
xdata = as.matrix(exp_data[,metadata$sample])
colSpecies = gsub(" ", "_", metadata$ensembl_datasets)

eve_output <- betaSharedTest(tree = tree, gene.data = xdata, colSpecies = colSpecies)
save(eve_output, file = paste(out, "/eve_", s, t, ".rDATA", sep = ""))


