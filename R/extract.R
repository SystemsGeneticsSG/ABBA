sink(file="/dev/null")
suppressWarnings
suppressMessages
extract_DMRs <- function(filename,chr,fdr){

chr_details <- read.delim(filename, header=F,sep = ",")
tmpenv <- new.env()
load(fdr,envir=tmpenv)
ds<-dim(chr_details)
cutoffs <- tmpenv$fdr_results[[2]]
d <- matrix(data=0,nrow=ds[1],ncol=1)
d[which(chr_details[,5]<cutoffs[1])]<-1
d[which(chr_details[,5]>cutoffs[2])]<-1
dens <- matrix(data=0,nrow=ds[1],ncol=1)
diffs<-chr_details[,5]
length_cutoff<- 4
density_cutoff<- 0.2
start<-0
stop<-0
density_start<-0
density_stop<-0
density<-0
length<-0
density_length<-0
length_index<-1
density_index<-1
consecutive_results<-list()
density_results<-list()
for(i in 1:ds[1]){
  
  ######################length checking############################
  if(d[i]==1){
    if(start==0){
      start<-i
      length<-1
    }else{
      stop<-i
      length<-length+1
    }
  }else{
    if(length > length_cutoff){
      m_df <- mean(diffs[start:stop])
      s_df <- sd(diffs[start:stop])
      lengths_out<- chr_details[stop,2]-chr_details[start,2]
      CpGdense<-length/lengths_out;
      consecutive_results[[length_index]]<-c(chr,chr_details[start,2],chr_details[stop,2],length,1,m_df,"length",lengths_out,CpGdense,s_df)
      length_index<-length_index+1
      #print(paste("length",chr_details[start,1],chr_details[stop,1],length,1))
    }
    stop<-0
    start<-0
    length<-0
  }
  
  
  ########################density checking###########################
  span<-length_cutoff/2
  if(i>(span+1)&&(i<ds[1]-span)){
    total<-sum(d[(i-span):(i+span)])
    density<-total/(length_cutoff+1)
    dens[i]<-density
    if(density>density_cutoff){
      if(density_start==0){
        density_start<-i
        density_length<-1
      }else{
        density_stop<-i
        density_length<-density_length+1
      }
    }else{
      if(density_length > length_cutoff){
        tden<-mean(dens[density_start:density_stop])
        dfden<-mean(diffs[density_start:density_stop])
        s_df <- sd(diffs[density_start:density_stop])
        den_lengths_out<- chr_details[density_stop,2]-chr_details[density_start,2]
        den_CpGdense<-density_length/den_lengths_out;
        density_results[[density_index]]<-c(chr,chr_details[density_start,2],chr_details[density_stop,2],density_length,tden,dfden,"density",den_lengths_out,den_CpGdense,s_df)
        density_index<-density_index+1
        #print(paste("density",chr_details[density_start,1],chr_details[density_stop,1],density_length,tden))
      }
      density_stop<-0
      density_start<-0
      density_length<-0
    }
  }
}
if(length(density_results) > 0){
  dens4file <- matrix(unlist(density_results), ncol = 10, byrow = TRUE)
  write.table(dens4file, file = paste0(filename,"density.DMRs.bed"),row.names=FALSE, na="",col.names=FALSE, sep=",",quote=F)

}
if(length(consecutive_results) > 0){
  lens4file <- matrix(unlist(consecutive_results), ncol = 10, byrow = TRUE)
  write.table(lens4file, file = paste0(filename,"length.DMRs.bed"),row.names=FALSE, na="",col.names=FALSE, sep=",",quote=F)
}
}



args<-commandArgs(trailingOnly = TRUE)
filename<-args[[1]]
chr<-args[[2]]
fdr<-args[[3]]
#filename<-"~/temp/Flantest/chr_details.sorted"
#chr<-"chr10"

extract_DMRs(filename,chr,fdr)
