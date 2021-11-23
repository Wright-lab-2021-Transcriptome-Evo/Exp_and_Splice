#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
#### LIBRARIES ----
#library(geiger)
#library(picante)
library(plotrix)
library(OUwie)
#library(ouch)
#library(phangorn)
#library(ggplot2)
library(dplyr)
#library(VennDiagram)
#library(evemodel)
#library(tidyr)
#library(ape)
library(phytools)
#library(ensembldb)

#### IMPORTING AND PREPARING DATA ####
tree <- read.nexus(args[1])
exp_data <- read.csv(args[2], row.names = 1)
metadata <- read.csv(args[3], header = F)
colnames(metadata) <- c("code", 'species', 'sex', 'tissue', 'sample', 'ensembl_datasets')
begin <-as.numeric(args[4])
start <- (begin*50)-49
stop <- start+49
s = args[5]
t = args[6]
out = args[7]

metadata = filter(metadata, sex == s & tissue == t)

if (stop > nrow(exp_data))(stop = nrow(exp_data))
xdata = exp_data[start:stop,metadata$sample] 
print(start)
print(stop)
n_species <- length(unique(metadata$species))
xdata <-xdata[1:2,]
#### FUNCTIONS ----
fit_ind_theta <- function(xdata, info, tree, n=10000, error_no_error = "none"){
  p <- list()
  expression_means <- matrix(nrow = nrow(xdata), ncol = length(unique(info$ensembl_datasets)))
  rownames(expression_means) <- rownames(xdata)
  colnames(expression_means) <- unique(info$ensembl_datasets)
  expression_se <- expression_means
  
  for (i in 1:nrow(xdata)){
    for (s in unique(info$ensembl_datasets)){
      inds <- info$sample[which(info$ensembl_datasets == s)]
      expression_means[i,s] <- mean(as.numeric(xdata[i,inds]))
      expression_se[i,s] <- std.error(as.numeric(xdata[i,inds]))
    }
  }
  
  
  for (i in 1:nrow(xdata)){
    print(paste("gene ", i, "is being run at the moment!!!"))
    reg = rep(c(1, 2), n_species)[1:n_species]
    trait_df <- data.frame("Genus_species" = gsub(" ", "_", colnames(expression_means)), "Reg" = reg, "X" = NA, "SE"=NA)
    trait_df[,3:4] <- list(expression_means[i,], expression_se[i,])
    names(reg) <- trait_df$Genus_species
    tree<-make.simmap(tree,reg)
    fitBM_var<-OUwie(tree,trait_df,model="BM1",simmap.tree=TRUE, mserr= error_no_error, ub = n, quiet = T)
    fitOU_var<-OUwie(tree,trait_df,model="OU1",simmap.tree=TRUE, mserr = error_no_error, ub = n, quiet = T)
    pi <- list(fitBM_var, fitOU_var)
    names(pi) <- c("fitBM_var", "fitOU_var")
    
    for (sp in 1:ncol(expression_means)){
      trait_df$Reg = rep(1)
      trait_df$Reg[sp] = 2
      reg2 = trait_df$Reg
      names(reg2) = trait_df$Genus_species
      tree<-make.simmap(tree,reg2)
      fitOU_indtheta<-OUwie(tree,trait_df,model=c("OUM"), simmap.tree = TRUE, mserr = error_no_error, quiet = T)
      new_names <- c(names(pi), paste("indtheta", colnames(expression_means)[sp], sep = "_"))
      pi <- c(pi, list(fitOU_indtheta))
      names(pi) <- new_names
      
    }
    p_names <- c(names(p), rownames(xdata[i,]))
    p <- c(p, list(pi))
    names(p) <- p_names
  }
  return(p)
}

p <- fit_ind_theta(xdata, metadata, tree, n=10000, error_no_error = "none")
save(p, file = paste(out, "/ouwie_", start, "_", stop, s, t, ".rDATA", sep = ""))





