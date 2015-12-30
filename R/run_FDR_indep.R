source("R/FDR.R")
source("R/MM3C.R")
sink(file="/dev/null")


run_FDR_indep = function(filename){
  data <- read.csv(filename, header=F)
  fdr_results <- FDR(data[,5])
  save(fdr_results, file=paste0(filename,"_fdr.RData"))
}


args <- commandArgs(trailingOnly = TRUE)

run_FDR_indep(args[1])
