sink(file="/dev/null")
source("R/FDR.R")
source("R/MM3C.R")
suppressWarnings
suppressMessages
suppressPackageStartupMessages(require('INLA'))





###############################################################################
#creates bef file from inla results                                           #
###############################################################################
run_INLA_bedfile <-function(INLAresults,chrs,locs){
  #return(list(probs_a,probs_b,result$summary.random$pos1$mean,result$summary.random$pos2$mean,p_esta,p_estb,result,d,w1,w2));
  l<-length(INLAresults[[1]])
  if(l>0){
    bedfile <- matrix(data=0,nrow=l,ncol=12)
    for(i in 1:l){
      bedfile[i,1]<-chrs[i]
      bedfile[i,2]<-locs[i]
      bedfile[i,3]<-INLAresults[[1]][i]-INLAresults[[2]][i]
      bedfile[i,4]<-INLAresults[[5]][i]-INLAresults[[6]][i]
      bedfile[i,5]<-INLAresults[[1]][i]
      bedfile[i,6]<-INLAresults[[2]][i]
      bedfile[i,7]<-INLAresults[[5]][i]
      bedfile[i,8]<-INLAresults[[6]][i]
      bedfile[i,9]<-INLAresults[[3]][i]
      bedfile[i,10]<-INLAresults[[4]][i]
      bedfile[i,11]<-INLAresults[[11]][i]
      bedfile[i,12]<-INLAresults[[12]][i]
    }
    return(bedfile)
  }

}



###############################################################################
#creates the datatype for INLA and runs both bin and negbin form. It then     #
#performs FDR and saves the output to a bed file.                             #
###############################################################################
run_INLA_on_datafile <-function(filename,number_of_samples,number_of_replicas,type){

        #load the data from file
        dataset <- load_data_from_file(filename)
        #rename it so that it matches the form above
        output_path<-filename
        
        #run INLA on the data
        INLA_results <- INLA_for_real(dataset[[1]],number_of_samples,number_of_replicas,0,0.001,type,output_path)
        bed<-run_INLA_bedfile(INLA_results,dataset[[3]],dataset[[1]][,1])
        #write(bed,stderr())
        write.csv(bed, file = paste0(filename,type,".bed"),row.names=FALSE)

        #probability differences
        #binomial_prob_diff<-INLA_results_binomial[[1]]-INLA_results_binomial[[2]]
        #negbinomial_prob_diff<-INLA_results_negbinomial[[1]]-INLA_results_negbinomial[[2]]


        #do FDR
        #binomial_results<-doFDR_single(binomial_prob_diff,FDR_cutoff,restarts, its, output_path, dataset[[3]],1,min_number_of_CpGs,max_dist,filename,'binomial',INLA_results_binomial[[3]],INLA_results_binomial[[4]],INLA_results_binomial[[9]],INLA_results_binomial[[10]],INLA_results_binomial[[1]],INLA_results_binomial[[2]], dataset[[2]])
        #negbinomial_results<-doFDR_single(negbinomial_prob_diff,FDR_cutoff,restarts, its, output_path, dataset[[3]],1,min_number_of_CpGs,max_dist,filename,'negbinomial',INLA_results_negbinomial[[3]],INLA_results_negbinomial[[4]],INLA_results_negbinomial[[9]],INLA_results_negbinomial[[10]],INLA_results_negbinomial[[1]],INLA_results_negbinomial[[2]], dataset[[2]])
        #write(paste("fdr has been run"), stderr())

        #save the results to an RData set so that they can be integrogated afterwards
        save(INLA_results,file=paste(output_path,type,".RData"))

}



INLA_for_real <- function(data,number_samples,number_of_replicas,log_gamma_m,log_gamma_v,type,output_path){
  reformatted_for_INLA <- reformat_for_INLA_realdata(data,number_samples,number_of_replicas,output_path)

  if(type=='binomial'){
     INLA_results <- run_INLA_split(reformatted_for_INLA,log_gamma_m,log_gamma_v)
  }else if(type=='disperssion'){
    INLA_results <- run_INLA_negbin_dispersion(reformatted_for_INLA,log_gamma_m,log_gamma_v)
    save(INLA_results,file=paste0(output_path,".RData"))
  }else{
    INLA_results <- run_INLA_negbin(reformatted_for_INLA,log_gamma_m,log_gamma_v)  
  }
  return(INLA_results)
}

reformat_for_INLA_realdata <- function(d,number_of_samples,number_of_replicas,output_path){
  cols_per_rep<-2
  intro_cols<-4
	total <- number_of_samples*number_of_replicas
  dm <- dim(d)
  pos<- d[,2]
  #states <- d[,2]
  l<-dm[1];
  results=list() 
  #print(d)
  pos_mat <- matrix(data=NA,nrow=l,ncol=number_of_samples)
  for(i in 1:number_of_samples){
    pos_mat[,i] <- pos
    groupb<-seq(i,((number_of_samples*l)),by=number_of_samples)
    #print(groupb)
    indicator <- matrix(data=i,nrow=l,ncol=1)
      for(j in 1:number_of_replicas){
        col <- (((i-1)*(number_of_replicas*cols_per_rep))+((j-1)*cols_per_rep))+intro_cols+1
        x <- d[,col]
        n <- d[,(col+1)]
        coverage <- d[,(col+1)]
        #groupb <- matrix(data=i,nrow=dm[1],ncol=1)
        index <- ((i-1)*number_of_replicas)+j
        results[[index]]<-cbind(x,n,pos_mat,groupb,indicator,pos,coverage)

      }
      pos_mat <- matrix(data=NA,nrow=l,ncol=number_of_samples)
  }


  for_inla <- do.call(rbind,results)
  colnames(for_inla)<-c("x","n","pos1","pos2","groupb","indicator","pos","coverage")
  for_inla<-as.data.frame(for_inla)
  for_inla<-for_inla[with(for_inla,order(pos,groupb)),]
  save(for_inla,file=paste0(output_path,"for_inla.RData"))
  write.table(for_inla,file=paste0(output_path,"for_inla.txt"),row.names = F,col.names = F,sep = ",")
  #print(for_inla[1:30,])
  return(for_inla)
}

run_INLA_split <- function(d,log_gamma_m,log_gamma_v){
  library(INLA)
    t<-inla.models()
        t$latent$rw1$min.diff = NULL
        assign("inla.models", t, INLA:::inla.get.inlaEnv())



    formula_1=x~indicator+ f(groupb,model="iid") +f(pos1,model="rw1",hyper = list(prec = list(prior="loggamma",param=c(0.1,0.001))))
    formula_2=x~indicator+ f(groupb,model="iid") +f(pos2,model="rw1",hyper = list(prec = list(prior="loggamma",param=c(0.1,0.001))))

    result_1<-inla(formula_1,data=d[is.na(d$pos2),],family="binomial",Ntrials=d$coverage[is.na(d$pos2)])
    result_2<-inla(formula_2,data=d[is.na(d$pos1),],family="binomial",Ntrials=d$coverage[is.na(d$pos1)])



    FullLength = length(result_1$summary.random$groupb$mean)
    a1<-result_1$summary.random$groupb$mean + result_1$summary.random$pos1$mean
    a2<-result_2$summary.random$groupb$mean + result_2$summary.random$pos2$mean
    intercept_1=result_1$summary.fixed[[1]][1]
    intercept_2=result_2$summary.fixed[[1]][1]
    #mean_difference=intercept+result$summary.fixed[[2]]
    w2 = a2 + intercept_2
    w1 = a1 + intercept_1
    probs_a = matrix(data=0,nrow=length(result_1$marginals.random$pos1),ncol=1)
    probs_b = matrix(data=0,nrow=length(result_2$marginals.random$pos2),ncol=1)
    convert_a = matrix(data=0,nrow=length(result_1$marginals.random$pos1),ncol=1)
    convert_b = matrix(data=0,nrow=length(result_2$marginals.random$pos2),ncol=1)
      #intercept = matrix(data=intercept,nrow=length(result$marginals.random$pos),ncol=1)
      i<-1;
      for(name in names(result_1$marginals.random$pos1)){
        probs_a[i]<-(inla.emarginal(function(z) exp(z)/(1+exp(z)), marginal=eval(parse(text=paste("result_1$marginals.random$pos1$\'", name, "\'", sep='')))))
        i <- i+1;
      }
      i<-1;
      for(name in names(result_2$marginals.random$pos2)){
        probs_b[i]<-(inla.emarginal(function(z) exp(z)/(1+exp(z)), marginal=eval(parse(text=paste("result_2$marginals.random$pos2$\'", name, "\'", sep='')))))
        i <- i+1;
      }
      #plot(probs_a,ylim=c(0,1),type='l')
      #lines(probs_b,col=2)
    p_esta<-exp(w1)/(1+exp(w1))
    p_estb<-exp(w2)/(1+exp(w2))
    #print("mlik")
  # print(result$mlik)
    return(list(probs_a,probs_b,result_1$summary.random$pos1$mean,result_2$summary.random$pos2$mean,p_esta,p_estb,result_1,d,w1,w2,result_1$summary.random$pos1$sd,result_2$summary.random$pos2$sd));
    #return(list(p_esta,p_estb,result$summary.random$pos1$mean,result$summary.random$pos2$mean,p_esta,p_estb));
}


run_INLA_negbin_dispersion <- function(d,m,v){
  library(INLA)
   #E <- rep(1,length(d))
    formula=x~indicator+ f(groupb,model="iid") +f(pos1,model="rw1")+ f(pos2,model="rw1")
    result<-inla(formula,data=d,family="nbinomial",control.inla = list(h = 0.001),num.threads = 16,control.fixed= list(prec.intercept = 0.01),control.compute=list(dic=T,mlik=T))
    #summary(result)
    #write(summary(result), stderr())
    FullLength = length(result$summary.random$groupb$mean)
    a1<-result$summary.random$groupb$mean[seq(1,FullLength,by=2)] + result$summary.random$pos1$mean
    a2<-result$summary.random$groupb$mean[seq(2,FullLength,by=2)] + result$summary.random$pos2$mean
    intercept=result$summary.fixed[[1]]
    mean_difference=intercept-result$summary.fixed[[2]]
    w2 = a2 + mean_difference + intercept
    w1 = a1 + intercept
    probs_a = matrix(data=0,nrow=length(result$marginals.random$pos1),ncol=1)
    probs_b = matrix(data=0,nrow=length(result$marginals.random$pos2),ncol=1)
    intercept = matrix(data=intercept,nrow=length(result$marginals.random$pos1),ncol=1)
      i<-1;
      for(name in names(result$marginals.random$pos1)){
        probs_a[i]<-(inla.emarginal(function(z) exp(z), marginal=eval(parse(text=paste("result$marginals.random$pos1$\'", name, "\'", sep='')))))
        i <- i+1;
      }
      i<-1;
      for(name in names(result$marginals.random$pos2)){
        probs_b[i]<-(inla.emarginal(function(z) exp(z), marginal=eval(parse(text=paste("result$marginals.random$pos2$\'", name, "\'", sep='')))))
        i <- i+1;
      }

    p_esta_pre<-exp(w1)
    #print(paste("mean of dsd probs_a",mean(probs_a)))
    p_estb_pre<-exp(w2)
    size<-result$summary.hyperpar[1,1]
    p_esta<-size/(size+p_esta_pre)
    p_estb<-size/(size+p_estb_pre)
    probs_a<-size/(size+probs_a)
    probs_b<-size/(size+probs_b)
    #print(paste("mean of probs_a",mean(probs_a)))
    #plot(probs_a,ylim=c(0,1),type='l')
    #lines(probs_b,col=2)
    #print("mlik")
  # print(result$mlik)
    return(list(probs_a,probs_b,result$summary.random$pos1$mean,result$summary.random$pos2$mean,p_esta,p_estb,result,d,w1,w2,result$summary.random$pos1$sd,result$summary.random$pos2$sd));
    #return(list(p_esta,p_estb,result$summary.random$pos1$mean,result$summary.random$pos2$mean,p_esta,p_estb));
}


run_INLA_negbin_split <- function(d,log_gamma_m,log_gamma_v){
  library(INLA)


    formula_1=x~indicator+ f(groupb,model="iid") +f(pos1,model="rw1",hyper = list(prec = list(prior="loggamma")))
    formula_2=x~indicator+ f(groupb,model="iid") +f(pos2,model="rw1",hyper = list(prec = list(prior="loggamma")))

    #result_1<-inla(formula_1,data=d,family="nbinomial", num.threads=35)
    #result_2<-inla(formula_2,,data=d,family="nbinomial", num.threads=35)


    result_1<-inla(formula_1,data=d[is.na(d$pos2),],family="nbinomial", num.threads=35)
    result_2<-inla(formula_2,data=d[is.na(d$pos1),],family="nbinomial", num.threads=35)


    FullLength = length(result_1$summary.random$groupb$mean)
    a1<-result_1$summary.random$groupb$mean + result_1$summary.random$pos1$mean
    a2<-result_2$summary.random$groupb$mean + result_2$summary.random$pos2$mean
    intercept_1=result_1$summary.fixed[[1]][1]
    intercept_2=result_2$summary.fixed[[1]][1]
    #mean_difference=intercept+result$summary.fixed[[2]]
    w2 = a2 + intercept_2
    w1 = a1 + intercept_1
    probs_a = matrix(data=0,nrow=length(result_1$marginals.random$pos1),ncol=1)
    probs_b = matrix(data=0,nrow=length(result_2$marginals.random$pos2),ncol=1)
      #intercept = matrix(data=intercept,nrow=length(result$marginals.random$pos),ncol=1)
      i<-1;
      for(name in names(result_1$marginals.random$pos1)){
        probs_a[i]<-(inla.emarginal(function(z) exp(z)/(1+exp(z)), marginal=eval(parse(text=paste("result_1$marginals.random$pos1$\'", name, "\'", sep='')))))
        i <- i+1;
      }
      i<-1;
      for(name in names(result_2$marginals.random$pos2)){
        probs_b[i]<-(inla.emarginal(function(z) exp(z)/(1+exp(z)), marginal=eval(parse(text=paste("result_2$marginals.random$pos2$\'", name, "\'", sep='')))))
        i <- i+1;
      }
      #plot(probs_a,ylim=c(0,1),type='l')
      #lines(probs_b,col=2)
    p_esta<-exp(w1)/(1+exp(w1))
    p_estb<-exp(w2)/(1+exp(w2))
    #print("mlik")
  # print(result$mlik)
    return(list(probs_a,probs_b,result_1$summary.random$pos1$mean,result_2$summary.random$pos2$mean,p_esta,p_estb,result_1,d,w1,w2,result_1$summary.random$pos1$sd,result_2$summary.random$pos2$sd));
    #return(list(p_esta,p_estb,result$summary.random$pos1$mean,result$summary.random$pos2$mean,p_esta,p_estb));
}

###############################################################################
#reads a file formatted for the benchmarking function, this is normally the   #
#file created by the simulation script but this function could be called from #
#elsewhere with a userdefined filename                                                                            #
###############################################################################
load_data_from_file <- function(filename){
        print(paste('loading',filename))
        data <- read.table(filename,header = F)
        locs <- data[,1]
        states <- data[,2]
        
        return(list(data,locs,states))
}



args <- commandArgs(trailingOnly = TRUE)
#print(args[1])
#print(args[2])
#print(args[3])
#print(args[4])
run_INLA_on_datafile(args[1],as.numeric(args[2]),as.numeric(args[3]),args[4])

#filename,number_of_samples,number_of_replicas,type