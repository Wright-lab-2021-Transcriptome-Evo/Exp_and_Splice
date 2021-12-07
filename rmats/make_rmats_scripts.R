library(dplyr)
args = commandArgs(trailingOnly=TRUE)

metadata <- read.csv(args[1], header = F)
#metadata <- read.csv("data/nextflow/project_data.csv", header = F)
colnames(metadata) <- c("code", 'species', 'sex', 'tissue', 'sample', 'ensembl_datasets')
wdir <- args[2]
#wdir <- "/fastdata"
dir.create(paste(wdir, "/rmats", sep = ""))
dir.create(paste(wdir, "/rmats/wdir", sep = ""))

species <- unique(metadata$species)
for (s in species){
  ss <- filter(metadata, species == s)
  path_m <- c()
  for (i in ss$code[ss$sex == "M"]){
    temp_path <- paste(wdir, "/hisat_allign/", s, "_", i, ".bam", sep = "")
    path_m <- c(path_m, temp_path)
  } 
  available <- gsub("//", "/", Sys.glob(paste(wdir, "/hisat_allign/*", sep = "")))
  path_m <- path_m[gsub("//", "/",path_m) %in% available]
  fileConn<-file(paste(wdir, "/rmats/",  s, "_M_path.txt", sep = ""))
  writeLines(paste(path_m, collapse = ","), fileConn)
  close(fileConn)
  
  path_f <- c()
  for (i in ss$code[ss$sex == "F"]){
    temp_path <- paste(wdir, "/hisat_allign/", s, "_", i, ".bam", sep = "")
    path_f <- c(path_f, temp_path)
  }
  available <- gsub("//", "/",Sys.glob(paste(wdir, "/hisat_allign/*", sep = "")))
  path_f <- path_f[gsub("//", "/",path_f) %in% available]
  fileConn<-file(paste(wdir,  "/rmats/",s, "_F_path.txt", sep = ""))
  writeLines(paste(path_f, collapse = ","), fileConn)
  close(fileConn)
                 
  fileConn<-file(paste("rmats_", s, ".sh", sep = ""))
  writeLines(c("#!/bin/bash", "",
               "#$ -l h_rt=5:0:0", "",
               "#$ -l rmem=4G",  "",
               "#$ -pe smp 4",  "",
               paste("#$ -wd /", wdir, "/rmats/wdir", sep = ""), "",
	       "source /usr/local/extras/Genomics/.bashrc", "",
	       "module load libs/lapack/3.4.2-5/binary", "",
	       "module load libs/gsl/2.4/gcc-6.2", "",
	       "module load apps/python/anaconda2-4.2.0", "",
	       "module load libs/blas/3.4.2-5/binary", "",
	       "conda activate rmats", "",
               paste("rmats --b1 ", wdir, "/rmats/", s, "_F_path.txt --b2 ", wdir, "/rmats/", s, "_M_path.txt --gtf ", 
                     wdir, "/gtf/", s, ".gtf -t paired --readLength 100 --od ", wdir, "/rmats", 
                     sep = "")
               ), fileConn)
  close(fileConn)
  
}



