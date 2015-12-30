sink(file="/dev/null")
suppressWarnings
suppressMessages
suppressPackageStartupMessages(require(ggplot2))
suppressPackageStartupMessages(require(ggthemes))
args <- commandArgs(trailingOnly = TRUE)
draw_block <- function(p,x1,x2,y1,y2,max,min,colour,label_text){
  
  if(x1<min(inla[,2])){x1<-min(inla[,2])}
  if(x2>max(inla[,2])){x2<-max(inla[,2])}
  data <- data.frame(x=c(x1,x1,x2,x2),y=c(y1,y2,y2,y1))
  lab_x <- (x1+x2)/2
  lab_y <- (y1+y2)/2
  lab_data <- data.frame(x=c(lab_x),y=c(lab_y),name=label_text)
  p <- p + geom_polygon(data=data, aes(x, y), fill=colour, linetype=1, color=colour)
  p <- p + geom_text(data=lab_data, aes(x, y, label = name), size=6)
  return(p)
}

plot_fancy_fig <- function(dmr,inla,raw,repeats,chr,cpg,genes,mirna,outfile,start,stop,tfbs,tfx){
scatter <- as.data.frame(raw)
colnames(scatter)<-c("chr","loc1","loc2","state","perc")
scatter$shape <- scatter$state + 2
scatter$state[scatter$state==1]<-"#000099"
scatter$state[scatter$state==2]<-"#CC0000"
remove_these <- which(inla[,3]=='NULL')
if(!length(remove_these)==0){
inla<-inla[-which(inla[,3]=='NULL'),]
inla[,1]<-as.matrix(inla[,1])
inla[,2]<-as.numeric(as.matrix(inla[,2]))
inla[,3]<-as.numeric(as.matrix(inla[,3]))
inla[,4]<-as.numeric(as.matrix(inla[,4]))
inla[,5]<-as.numeric(as.matrix(inla[,5]))
inla <- as.data.frame(inla)
}

colnames(inla) <- c("chr","locus","diff","percentage_methylation","b")
min_inla<-min(inla[,2])
max_inla<-max(inla[,2])
p <- ggplot(inla, aes(x=locus,y=percentage_methylation)) + geom_line(color="#000099",linetype=1,size=1.5)  + scale_x_continuous(expand=c(0,0)) + 
  scale_y_continuous(breaks=c(0,0.5,1)) +
  scale_color_fivethirtyeight()+ theme_fivethirtyeight() + xlab(paste("chromosome ",chr))
p <- p + geom_line(data=inla,aes(x=locus,y=b),color="#CC0000",linetype=1,size=1.5)
                   
p <- p + geom_point(data=scatter, aes(x=loc1, y=perc),color=scatter$state,shape=scatter$shape ) + ggtitle(paste('ABBA DMR on',chr,'between',start,'and',stop))

inla_dims <- dim(inla)
dmr_dims <- dim(dmr)
gene_dims <- dim(genes)

for(j in 1:dmr_dims[1]){
p <- draw_block(p,dmr[j,2],dmr[j,3],1,0,min_inla,max_inla,"#d2062926","")
}

y_top_level = -0.15
y_bottom_level = -0.2
#p <- p + geom_polygon(data=data, aes(x, y), fill="#d8111818", linetype=2, col="#d2062926")
if(!is.null(gene_dims[1])){
for(j in 1:gene_dims[1]){
p <- draw_block(p,genes[j,2],genes[j,3],y_top_level,y_bottom_level,min_inla,max_inla,"#99999999",paste(genes[j,4],genes[j,9],"(",genes[j,8],")"))
y_top_level <- y_top_level - 0.07
y_bottom_level <- y_bottom_level - 0.07
} 
}
ggsave(file=outfile,width=10,height=5)
return(p)
}

outfile<- args[1];
#print(outfile)
path = outfile

file.names <- dir(path, pattern =".RData$")

for(i in 1:length(file.names)){
tryCatch({load(paste0(path,file.names[i]))

#print(paste(i,"from",length(file.names)))
outfile<-paste0(path,file.names[i],"fancy.pdf")
#print(paste("processing",file.names[i],"output to",outfile))
#print(outfile)
fig<-plot_fancy_fig(dmr,inla,raw,repeats,chr,cpg,genes,mirna,outfile,start,stop,tfbs,tfx)

})
}
