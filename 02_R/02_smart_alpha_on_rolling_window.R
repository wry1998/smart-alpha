library(gurobi) # optimization tool

########## solve for optimal portfolio weight ################################
opt = function(spca,eplison){     
  ## initial
  f = spca$f
  alpha = spca$alpha
  lambda = spca$lambda
  cov_F = cov(f)
  sigma = lambda %*% cov_F %*% t(lambda)
  N = length(alpha)
  
  ## model setup
  model = list()
  model$Q = sigma
  model$A = rbind(alpha,rep(1,N))
  model$rhs = c(eplison,1)
  model$sense = c('>','=')
  model$ub = rep(0.02,N)
  params <- list()
  params$method = 2
  params$NonConvex = 1
  params$OutputFlag = 0
  params$ResultFile = 'model.sol'
  
  result <- gurobi(model, params)
  return(result$x) ## return optimized weight
}



######### rolling window process, with dynamic factors generated via sparse-pca #####################
rolling_spca = function(data, rho, eplison){
  t = dim(data)[1]
  N = dim(data)[2]
  month = floor(t/21) ## number of trading month in dataset
  
  return = c()
  weight_new = rep(1/N,N)
  turnover = 0
  for(n in 0:(month-13)){
    weight_old = weight_new
    R = data[(n*21+1):((n+12)*21),] ## train
    R_test = data[((n+12)*21+1):((n+12)*21+21),] ## test
    
    ## compute weight
    m = m_opt(R,10)   # set mmax to be 10 rather than 50 to save running time, as optimal is usually 2-4
    spca = SPCA(rho,R,m)
    weight_new = opt(spca,eplison)
    turnover = turnover+sum(abs(weight_new-weight_old)) #turnover
    
    ## test performance
    #    transaction = rep(log(1-0.25/100),N) %*% abs(weight_new-weight_old)
    r = R_test %*% weight_new
    return[n+1] = sum(r)#+transaction
  }
  turnover = turnover/(month-12)
  return(list(return=return,turnover=turnover))
}



######### rolling window process, with dynamic factors generated via pca #####################
rolling_pca = function(data, eplison){
  t = dim(data)[1]
  N = dim(data)[2]
  month = floor(t/21) ## number of trading month in dataset
  
  return = c()
  weight_new = rep(1/N,N)
  turnover = 0
  for(n in 0:(month-13)){
    weight_old = weight_new
    R = data[(n*21+1):((n+12)*21),] ## train
    R_test = data[((n+12)*21+1):((n+12)*21+21),] ## test
    
    ## compute weight
    m = m_opt(R,10)   # set mmax to be 10 rather than 50 to save running time, as optimal is usually 2-4
    spca = PCA(R,m)
    weight_new = opt(spca,eplison)
    turnover = turnover+sum(abs(weight_new-weight_old)) #turnover
    
    ## test performance
    #    transaction = rep(log(1-0.25/100),N) %*% abs(weight_new-weight_old)
    r = R_test %*% weight_new
    return[n+1] = sum(r)#+transaction
  }
  turnover = turnover/(month-12)
  return(list(return=return,turnover=turnover))
}



############################ some statistics to evaluate the performance of portfolio
perform= function(return,market){    # return is the smart alpha portfolio's return, market is the market portfolio's returm (benchmark)
  ### basic statistics
  t = length(return)
  raw = sum(return)
  avg = sum(return) /t *12
  sd = sd(return)/sqrt(t/12)
  rf=0.03
  sharpe = (avg-rf)/sd
  drop = min(return)
  
  ## lm
  x = market-log(1+rf)/12
  y=return-log(1+rf)/12
  lm=lm(y~x)
  alpha = lm$coefficients[1][[1]]*12
  beta = lm$coefficients[2][[1]]
  residual = sum(resid(lm)^2)/(t-1)*12
  excess = sum(return-(log(1+rf)/12+beta*(market-log(1+rf)/12)))/(t-1)*12
  AR = alpha/beta
  
  return(c(raw,avg,sd,sharpe,drop,abs(beta),residual,alpha,excess,abs(AR)))
}