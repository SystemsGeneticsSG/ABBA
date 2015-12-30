sink(file="/dev/null")
args <- commandArgs(trailingOnly = TRUE)

#read in arguments
outfile<- args[1];

chr<-args[2];
start<-as.numeric(args[3]);
stop<-as.numeric(args[4]);
#start<-start-10000
#stop<-stop+10000
DMR_file <- args[5];
Gene_file <- args[6];
Repeat_file <- args[7];
tfbs_file <- args[8];
mirna_file <- args[9];
raw_file <- args[10];
tfx_file <- args[11];
cpg_file <- args[12];
inla_file <- args[13];
add.alpha <- function(col, alpha=1){
if(missing(col))
stop("Please provide a vector of colours.")
apply(sapply(col, col2rgb)/255, 2,
function(x)
rgb(x[1], x[2], x[3], alpha=alpha))
} 

generate_area_figs <-function (outfile,start,stop,chr,DMR_file,Gene_file,Repeat_file,tfbs_file,mirna_file,raw_file,tfx_file,cpg_file,inla_file){
  library(scales)
  dmr <- 0
  genes <- 0
  repeats <- 0
  tfbs<-0
  mirna<-0
  raw<-0
  tfx<-0
  cpg<-0
  inla<-0
  tryCatch({
  dmr <- read.delim(DMR_file, header=F, sep = "|")
  }, error=function(e) NULL)
  tryCatch({
  genes <- read.delim(Gene_file, header=F, sep = "|")
  }, error=function(e) NULL)
  tryCatch({
  repeats <- read.delim(Repeat_file, header=F, sep = "|")
  }, error=function(e) NULL)
  tryCatch({
  tfbs <- read.delim(tfbs_file, header=F, sep = "|")
  }, error=function(e) NULL)
  tryCatch({
  tfx <- read.delim(tfx_file, header=F, sep = "|")
  }, error=function(e) NULL)
  tryCatch({
  mirna <- read.delim(mirna_file, header=F, sep = "|")
  }, error=function(e) NULL)
  tryCatch({
  raw <- read.delim(raw_file, header=F, sep = "|")
  }, error=function(e) NULL)
  tryCatch({
  cpg <- read.delim(cpg_file, header=F, sep = "|")
  }, error=function(e) NULL)
  tryCatch({
  inla <- read.delim(inla_file, header=F, sep = "|")
  }, error=function(e) NULL)

  
  pdf(outfile,width=10,height=5)
  bps<-c(start,stop)
  yp<-0

#plot(d[,2],d[,4],type='b',pch='x',ylim=c(0,1))
#lines(d[,2],d[,5],type='b',pch='x',col='red')
  if(length(raw)!=1){
    plot(raw[,2],raw[,5],pch='.',ylim=c(-1.5,1.2),col=add.alpha(raw[,4],0.5),main=paste("chr",chr,"between",start,"and",stop))
    #points(raw[,2],raw[,5],pch='.',col=add.alpha('red',0.5))
    grid(ny = 3, nx=20, col = "lightgray", lty = "dotted")
  }else{
    plot(bps,rep(0, length(bps)),yaxt='n',pch='.',ann=FALSE,ylim=c(-1.5,1.5),main=paste("chr",chr,"between",start,"and",stop))
    grid(ny = 0, nx= 20, col = "lightgray", lty = "dotted")
  }
  if(length(genes)!=1){
    print(genes)
    print(start)
    print(stop)
    
    for(i in 1:dim(genes)[1]){
      
      yp<-yp-0.08
      segments(genes[i,2],yp,genes[i,3],yp,col="black",lwd=2,lend=2)
      if((stop<genes[i,3])&&(start>genes[i,2])){
        middle <- (start+stop)/2
        text(middle,(yp+0.03),labels=paste(genes[i,4],genes[i,5],genes[i,9]),cex=0.25)
      }else if(stop<genes[i,3]){
        text(genes[i,2],(yp+0.03),labels=paste(genes[i,4],genes[i,5],genes[i,9]),cex=0.25)
      }else if(start>genes[i,2]){
        text(genes[i,3],(yp+0.03),labels=paste(genes[i,4],genes[i,5],genes[i,9]),cex=0.25)
      }else{
        text(genes[i,2],(yp+0.03),labels=paste(genes[i,4],genes[i,5],genes[i,9]),cex=0.25)
      }
      
      
    }
  }
  yp <- yp-0.05
  if(length(repeats)!=1){
  segments(repeats[,2],yp,repeats[,3],yp,col="yellow",lwd=2,lend=2)
  #text(repeats[,2],0.45,labels=repeats[,5],srt=90,cex=0.5)
  }

  yp <- yp-0.05
  if(length(cpg)!=1){
  segments(cpg[,2],yp,cpg[,3],yp,col="green",lwd=2,lend=2)
  #text(repeats[,2],0.45,labels=repeats[,5],srt=90,cex=0.5)
  }
 
  yp <- yp-0.05
  if(length(tfx)!=1){
  segments(tfx[,2],yp,tfx[,3],yp,col="red",lwd=2,lend=2)
  #text(tfx[,2],yp+0.03,labels=tfx[,5],cex=0.25,srt=90)
  }

  yp <- yp-0.05
  if(length(tfbs)!=1){
  segments(tfbs[,2],yp,tfbs[,3],yp,col="red",lwd=2,lend=2)
  text(tfbs[,2],yp+0.03,labels=tfbs[,5],cex=0.25,srt=90)
  }

  yp <- yp-0.05
  if(length(mirna)!=1){
      for(i in 1:dim(mirna)[1]){
      yp<-yp-0.08  
  segments(mirna[i,2],yp,mirna[i,3],yp,col="green",lwd=2,lend=2)
  text(mirna[i,2],yp+0.03,labels=mirna[i,5],cex=0.25)
      }
  }

  yp <- yp-0.05
  if(length(dmr)!=1){
  for(i in 1:dim(dmr)[1]){
      yp<-yp-0.08  
  segments(dmr[i,2],yp,dmr[i,3],yp,col="pink",lwd=2,lend=2)
  text(dmr[i,2],yp+0.03,labels=paste(dmr[i,4],dmr[i,5],dmr[i,6],dmr[i,8],dmr[i,7],dmr[i,9]),cex=0.25)
}
  }

  
  save(dmr,genes,repeats,tfbs,mirna,raw,tfx,cpg,inla,start,stop,chr,outfile,file=paste0(outfile,".RData"))
  dev.off()
}

generate_area_figs(outfile,start,stop,chr,DMR_file,Gene_file,Repeat_file,tfbs_file,mirna_file,raw_file,tfx_file,cpg_file,inla_file)



