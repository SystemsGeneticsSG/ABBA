MM3C = function(x, FDR_mixture = 0.10, iter_max = 1000)
{

x = sort(x)
n = length(x)
x = as.matrix(x)
n_x = nrow(x)
p_x = ncol(x)

if (n_x < p_x)
{
    x = t(x)
}

n_x = nrow(x)
p_x = ncol(x)


###################
# Starting values #
###################

k = 3  # ***
mad0 = mad(x, center = 0)

m = c(0, 0, 0)
m[1] = 2 * (-1.96 * mad0)               # forced starting
m[2] = rnorm(1, mean = 0, sd = mad0)    # forced starting
m[3] = 2 * (1.96 * mad0)                # forced starting


s = c(0, 0, 0)
s[1] = 0.5 * mad0   # quantile(x, 0.25, names = F) - m[1]
s[2] = mad0
s[3] = 0.5 * mad0   # m[3] - quantile(x, 0.75, names = F)

p = c(0.025, 0.95, 0.025)   # forcing large p for null


###################
# Starting values #
###################

eps = 2.2204e-016

mhist = m
shist = s
phist = p
L = -10 ^10
Lhist = L

w = matrix(0, n, k)
d = matrix(0, n, k)
ww = matrix(0, n, k)

iter = 0
breakcond = 0
stop_code = NA

while (breakcond != 1)
{
    
        
####################
# Shift parameters #
####################
    
    m0 = m
    s0 = s
    p0 = p
    L0 = L
    
    
##########
# E-step #
##########
    
    for (i in 1 : k)
    {
       # r = dnorm(x, m[i], s[i])
       # w[, i] = (p[i] * r)+1e-239
       # d[, i] = (r)+1e-239
        r = dnorm(x, m[i], s[i])
        w[, i] = (p[i] * r)
        d[, i] = (r)
    }
    
    w = w / (rowSums(w) %*% t(rep(1, k)))
    p = t(colMeans(w))
    
    idx_1 = which(w[ , 1] > w[ , 2])
    idx_3 = which(w[ , 2] < w[ , 3])
    ext_set = union(idx_1, idx_3)
    
    if (length(ext_set) != 0)
    {
        int_set = setdiff(seq(1, n_x), ext_set)
        FDR_1 = mean(w[int_set, 1])
        FDR_3 = mean(w[int_set, 3])
        FNR_2 = mean(w[ext_set, 2])
        FDR = (FDR_1 + FDR_3)
        # print(FDR)
    }
    
    if (length(ext_set) == 0)
    {
        FDR = 0
    }
    
    #print(FDR)
    
    
#####################
# Break criterion I #
#####################

    if (iter_max > 0)
    {
        
        if (FDR_mixture < FDR)
        {
            stop_code = "FDR_stopping"
            breakcond = 1
        }
        
    }
        
    
##########
# M-step #
##########
    
    for (i in 1 : k)
    {
        ww[, i] = p[i] * d[, i]
    }
    L = sum(log(rowSums(ww)));
    m = t((t(w) %*% x) / colSums(w))
    m[2] = 0   # forcing component mean == 0
    x_m_2 = (x %*% rep(1, k) - rep(1, n) %*% m) ^2
    s =  t(sqrt((colSums(w * x_m_2) / colSums(w))))
    
    if (s[1] < eps)
    {
        s[1] = eps
    }
    
    if (s[2] < eps)
    {
        s[2] = eps
    }
    
    if (s[3] < eps)
    {
        s[3] = eps
    }
    
    mhist = rbind(mhist, m)
    shist = rbind(shist, s)
    phist = rbind(phist, p)
    Lhist = c(Lhist, L)
    iter = iter + 1
    
    # print(m)
    # print(s)
    # print(p)
    # print(FDR)
    # print(mhist)
    # print(shist)
    # print(phist)
    # print(Lhist)
    # print(iter)
    
    
######################
# Break criterion II #
######################
    
    difL = abs(L - L0)
    dif = max(abs(c(m, s, p) - c(m0, s0, p0)))
    
    # if (difL < eps)
    # {
    #   print(L0)
    #   print(L)
    #   break
    # }
    
    if (iter_max < 0)
    {
        breakcond = 1
    }
    
    if (iter_max > 0)
    {
        
        if (dif < eps | iter == iter_max)
        {
            stop_code = "Convergence_reached"
            breakcond = 1
        }
        
    }
     
}

# print(c(breakcond, iter))

return(list(m = m, s = s, p = p, mhist = mhist[-1, ], shist = shist[-1, ], phist = phist[-1, ], Lhist = Lhist[-1], stop_code = stop_code))
}
