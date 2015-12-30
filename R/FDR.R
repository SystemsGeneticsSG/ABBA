sink(file="/dev/null")
suppressWarnings
suppressMessages

FDR = function(x, FDR_level = 0.05, rstart = 10, FDR_mixture = 0.10, iter_max = 1000)
{

x = sort(x)
q_1 = quantile(x, 1/4)
q_3 = quantile(x, 3/4)
idx_1 = which(x < q_1)
idx_3 = which(x > q_3)
x_tmp = x[-c(idx_1, idx_3)]
d = density(x_tmp)
mode_x = d$x[which(d$y == max(d$y))]
x = x - mode_x 
n = length(x)

k = 3
m = matrix(NA, rstart, k)
s = matrix(NA, rstart, k)
p = matrix(NA, rstart, k)
L = matrix(NA, rstart, 1)
stop_code = matrix(NA, rstart, 1)

for (r in 1 : rstart)
{
    MM3C_out = MM3C(x, FDR_mixture = FDR_mixture, iter_max = iter_max)
    m[r, ] = MM3C_out$m
    s[r, ] = MM3C_out$s
    p[r, ] = MM3C_out$p
    L[r] = max(MM3C_out$Lhist)
  stop_code[r] = MM3C_out$stop_code
  #print(r)
}

idx = max(which(L == max(L)))
m = m[idx, ]
s = s[idx, ]
p = p[idx, ]
print(stop_code[idx])

w = matrix(0, n, k)

for (h in 1 : k)
{
    r = dnorm(x, m[h], s[h])
    w[, h] = p[h] * r
}

w = w / (rowSums(w) %*% t(rep(1, k)))
p = t(colMeans(w))

nFDR_level = length(FDR_level)
cutoff_level_tmp = matrix(data = NA, nrow = 1, ncol = nFDR_level)

for (i in 1 : nFDR_level)
{
  iter = 1
    FDR = 0
    
    while (FDR < FDR_level[i])
    {
        
        if (iter == n)
        {
            break
        }
        
      cutoff = sort(abs(x), decreasing = T)[iter]
        cutoffpos = cutoff
        cutoffneg = -cutoff
        
      if (cutoffpos < 0)
        {
            break
        }
        
        xposidx = which(x >= cutoffpos)
        xnegidx = which(x <= cutoffneg)
        nxpos = length(xposidx)
        nxneg = length(xnegidx)
      
        if (length(xnegidx) > 0)
        {
            wxneg = w[xnegidx, 2]
        }
        
      if (length(xnegidx) == 0)
        {
            wxneg = 0
        }
        
        if (length(xposidx) > 0)
        {
            wxpos = w[xposidx, 2]
        }
    
        if (length(xposidx) == 0)
        {
            wxpos = 0
        }
        
        FDR = (sum(wxneg) + sum(wxpos)) / (nxneg + nxpos)
        
        if (iter == 1)
        {
            cutoffhist = cutoff
            FDRhist = FDR
        }
        
        if (iter > 1)
        {
            cutoffhist = c(cutoffhist, cutoff)
            FDRhist = c(FDRhist, FDR)
        }
        
        iter = iter + 1
        
        
############
# Printing #
############
        
       # print(i)
         # print(iter)
         # print(cutoff)
         # print(FDR)
     # print(FDRhist)
    }
  
  if (nFDR_level == 1)
  {
      cutoff_level_tmp = cutoffhist[max(1, iter - 2)]   # ***
    xposidx = which(x >= cutoffpos[i])
        xnegidx = which(x <= cutoffneg[i])
        xidx = sort(c(xposidx, xnegidx))
  }
  
  if (nFDR_level > 1)
  {
      cutoff_level_tmp[i] = cutoffhist[max(1, iter - 2)]   # ***
  }
      
}


###############
# Recentering #
###############

m = m + mode_x

ncutoff_level = length(cutoff_level_tmp)
cutoff_level = matrix(data = NA, nrow = 2, ncol = ncutoff_level)
cutoff_level[1, ] = -cutoff_level_tmp + mode_x
cutoff_level[2, ] = cutoff_level_tmp + mode_x

if (nFDR_level == 1)
{   
  return(list(FDR_level = FDR_level, cutoff_level = cutoff_level, xidx = xidx, cutoffhist = cutoffhist, FDRhist = FDRhist, m = m, s = s, p = p))
}
  
if (nFDR_level > 1)
{
    return(list(FDR_level = FDR_level, cutoff_level = cutoff_level, m = m, s = s, p = p))
}
  
}
