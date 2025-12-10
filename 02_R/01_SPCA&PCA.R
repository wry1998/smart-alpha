############ compute optimal number of dynamic  #######################
m_opt = function(data,mmax){        # mmax is the maximum optimal number possible
  t = dim(data)[1]
  N = dim(data)[2]
  svd = svd(data,nu=mmax,nv=mmax)
  
  #for each m, compute IC
  IC = rep(0,mmax)
  for(m in 2:mmax){
    sigma = matrix(diag(svd$d[1:m]),ncol=m)
    F_hat = svd$u[,1:m] %*% sigma
    F_hat = F_hat/sqrt(sum(F_hat^2))
    F_hat = F_hat*sqrt(t)
    loadings = t(data) %*% F_hat /t
    error = data - F_hat %*% t(loadings)
    
    V = sum(error^2)/t/N
    C_TN = min(sqrt(N),sqrt(t))
    IC[m] = log(V)+m*(N+t)/N/t
  }
  IC = IC[-1]
  optimal = which.min(IC)+1
  return(optimal)
}


##################### SPCA ##################

### G matrix
regula = function(data,m,rho){    # m is the number of dynamic factors, rho is hyper-parameter hard-threshold 
  N = dim(data)[2]
  
  ## reorder return matrix by var
  data_ordered = data[,order(apply(data,2,var),decreasing = TRUE)]
  
  ## H, ordered as variance
  rho_hat = cor(data_ordered)
  H = matrix(rep(0,N^2),ncol = N)
  ind = which(abs(rho_hat)>=rho,arr.ind = TRUE)
  H[ind] = 1
  
  ## G
  H = H[,!duplicated(t(H))] #drop duplicate
  G=H[,1:m]
  return(G)
}

### update for B
B_update = function(G,A,data,N,m){
  B = matrix(rep(0,N*m),nrow=N)
  for(j in 1:m){
    D = matrix(diag(G[,j]),ncol = N)
    B[,j] = D %*% t(data) %*% data %*% A[,j]
  }
  return(B)
}

### update for A
A_update = function(data,B,m){
  svd_new = svd(t(data) %*% data %*% B, nu=m,nv=m)
  A = svd_new$u %*% t(svd_new$v)
  return(A)
}

### judge if solution already converage
is.conv = function(old,new){
  l = length(old)
  criteria = sum(abs(old-new))
  if(criteria <= l*0.0000001){
    return(TRUE)
  }else{
    return(FALSE)
  }
}

### main algorithm
SPCA = function(rho,R,m){ # R is the return dataset
  ## compute regularization matrix G
  G = regula(R,m,rho)
  
  ## initial
  N = dim(R)[2]
  svd = svd(R,nu=m,nv=m)
  A = svd$v[,1:m]
  B_new = 0
  conv = FALSE
  i=0  # record iteration number
  
  ## update until converge
  while(!conv && i<20){
    B_old = B_new
    B_new = B_update(G,A,R,N,m)
    A = A_update(R,B_new,m)
    conv = is.conv(B_old,B_new)
    i = i+1
  }
  
  ## lambda_spca
  lambda_spca = matrix(rep(0,N*m),nrow=N)
  for(k in 1:m){
    lambda_spca[,k] = B_new[,k] / sqrt(sum(B_new[,k]^2))
  }
  ## F_spca
  F_spca = R %*% lambda_spca
  ## alpha_spca
  alpha_spca = colMeans(R)-colMeans(F_spca) %*% t(lambda_spca)
  
  return(list(alpha = alpha_spca, f = F_spca, lambda = lambda_spca,i=i))
}




################################# PCA method ############################
PCA = function(data,m){  # m is number of dynamic factors
  t = dim(data)[1]
  N = dim(data)[2]
  svd = svd(data,nu=m,nv=m)
  sigma = matrix(diag(svd$d[1:m]),ncol=m)
  F_hat = svd$u[,1:m] %*% sigma
  F_hat = F_hat/sqrt(sum(F_hat^2))
  F_hat = F_hat*sqrt(t)
  lambda_hat = t(data) %*% F_hat /t
  alpha = colMeans(data)-colMeans(F_hat) %*% t(lambda_hat)
  return(list(alpha = alpha, f = F_hat, lambda = lambda_hat))
}





