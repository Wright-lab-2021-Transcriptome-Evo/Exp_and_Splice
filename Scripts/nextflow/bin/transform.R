#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

data=read.csv(args[1], sep = " ", header = FALSE)

data$V4 = rep(NA)

m_lengths = sapply(unique(data$V2), function(x)(mean(data$V1[data$V2 == x])))
names(m_lengths)=unique(data$V2)
mml=min(m_lengths)
nt=(which((m_lengths - mml) > 0.25 *mml))
`%notin%` <- Negate(`%in%`)
median=median(m_lengths[names(m_lengths) %notin% names(nt)])
data$V4[data$V2 %in% names(nt)] = median

write.csv(as.matrix(data), "transform_data.csv", quote = F)

