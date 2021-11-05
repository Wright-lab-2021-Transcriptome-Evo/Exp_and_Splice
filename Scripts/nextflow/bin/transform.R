#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
`%notin%` <- Negate(`%in%`)

data=read.csv(args[1], sep = " ", header = FALSE)
#data=read.csv("data/test_read_data/comp_read_counts.csv", sep = " ", header=F)

m_lengths = sapply(unique(data$V2), function(x)(mean(data$V1[data$V2 == x])))
names(m_lengths)=unique(data$V2)
mml=min(m_lengths)
nt=(which((m_lengths - mml) > 0.25 *mml))
median=median(m_lengths[names(m_lengths) %notin% names(nt)])

out <- as.data.frame(matrix(ncol = 2, nrow = length(m_lengths)))
out[,1] <- names(m_lengths)
out[,2] <- 0
out[,2][out[,1] %in% names(nt)] = (median)
colnames(out) = NULL

write.table(out, "transform_data.csv", quote = F, row.names = F)

