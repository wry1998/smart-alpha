############################## loading data ################
setwd('.../R/MRP')
library(stringr)
library(plyr)

### load for market (STOXX600) as benchmark for performance evaluation statistics
market = read.csv('^STOXX.csv',header = TRUE)[,5]
t = length(market)
return_market = log(market[2:t]/market[1:(t-1)])

### load for components of STOXX600
ticker = read.table('ticker_list.csv',sep=";",header=FALSE)[[1]] #load tickers
exchange = read.table('settle_list.csv',sep=";",header=FALSE)[[1]]

from=c("Frankfurt Stock Exchange",
       "London Stock Exchange",
       "Italian Stock Exchange",
       "Stockholm Stock Exchange",
       "Euronext Amsterdam",
       "SIX Swiss Exchange",
       "Euronext Paris",
       "Euronext Brussels",
       "Madrid Stock Exchange",
       "Irish Stock Exchange",  
       "Oslo Stock Exchange",
       "Copenhagen Stock Exchange",
       "Vienna Stock Exchange",
       "Xetra",
       "Euronext Lisbon",
       "Valencia Stock Exchange",
       "Warsaw Stock Exchange",
       "New York Stock Exchange",
       "Athens Exchange",
       "Helsinki Stock Exchange",
       "Barcelona Stock Exchange",
       "Berlin Stock Exchange",
       "Johannesburg Stock Exchange")
to = c(".DE",".L",".MI",".ST",".AS",".SW",".PA",".BR",".MC",".IR",".OL",
       ".CO",".VI",".DE",".LS",".MC",".WA","",".AT",".HE",".MC",".BE",".JO")
sufix = mapvalues(exchange, from, to, warn_missing = TRUE)
index = cbind(ticker,sufix)

setwd('...R/data_long')

data = c()
for(i in 1:nrow(index)){
  ticker = paste(index[i,1],index[i,2],sep='')
  ticker = paste(ticker,'csv',sep='.')
  temp = read.csv(ticker,header = TRUE)[,5] #close price
  n = length(temp)
  if(n<1710){   ##drop data with missing values
    next
  }
  return = log(temp[2:n]/temp[1:(n-1)]) #log return
  #  print(i) #check problem
  data = cbind(data,return)
}

data[is.na(data)] = 0   # replace NA with 0 (i.e. assume price stays the same)




################# optimal number of dynamic factors across time ###########
## rolling window process
rolling_m = function(data){
  t = dim(data)[1]
  N = dim(data)[2]
  month = floor(t/21) # number of trading month in dataset
  
  return = c()
  optimal_m = c()
  for(n in 0:(month-13)){
    R = data[(n*21+1):((n+12)*21),] ## train
    m = m_opt(R,10)  # set mmax to be 10 rather than 50 to save running time, as optimal is usually 2-4
    optimal_m[n+1] = m
  }
  return(optimal_m)
}

m = rolling_m(data)
date = seq(as.Date("2016-1-1"), as.Date("2021-12-31"), by = "months")
plot(m~date,type='l',xlab='Dates',ylab='Number of factors',main='Optimal m',ylim=c(1,4))




############ example to generate & evaluate portfolio ###################
rho = 0.2  # set hard threshold
eplison = 0.0005  # set alpha lower bound

### returns & turnover of smart-alpha portfolio with sparse-pca dynamic factors (each calculated over the 1-month testing period)
return_spca = rolling_spca(data, rho, eplison)$return 
turnover_spca = rolling_spca(data, rho, eplison)$turnover

### returns & turnover of smart-alpha portfolio with pca dynamic factors (each calculated over the 1-month testing period)
return_pca = rolling_pca(data, eplison)$return
turnover_pca = rolling_pca(data, eplison)$turnover

### performance evaluating statistics  
stats1 = perform(return_spca,return_market)
stats2 = perform(return_pca,return_market)
