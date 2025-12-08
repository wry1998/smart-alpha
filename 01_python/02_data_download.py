
import pandas as pd
import yfinance as yf
import os
settlement_msp = {
    "Frankfurt Stock Exchange":".DE",
    "London Stock Exchange":".L",
    "Italian Stock Exchange":".MI",
    "Stockholm Stock Exchange":".ST",
    "Euronext Amsterdam":".AS",
    "SIX Swiss Exchange":".SW",
    "Euronext Paris":".PA",
    "Euronext Brussels":".BR",
    "Madrid Stock Exchange":".MC",
    "Irish Stock Exchange":".L",  ####.L
    "Oslo Stock Exchange":".OL",
    "Copenhagen Stock Exchange":".CO",
    "Vienna Stock Exchange":".VI",
    "Xetra":".DE",
    "Euronext Lisbon":".LS",
    "Valencia Stock Exchange":".MC",
    "Warsaw Stock Exchange":".WA",
    "New York Stock Exchange":"",
    "Athens Exchange":".AT",
    "Helsinki Stock Exchange":".HE",
    "Barcelona Stock Exchange":".MC",
    "Berlin Stock Exchange":".BE",
    "Johannesburg Stock Exchange":".JO"
}


ticker_pd = pd.read_csv(r"...\data\ticker_list.csv")
settlement_pd = pd.read_csv(r"...\data\settle_list.csv")

base_dir = "...\data\raw_data"
def getHistoricalData(name):
    print("_____Start Processing" + name + "_____")
    ticker = yf.Ticker(name)
    aapl_historical = ticker.history(start="2016-01-01", end="2021-12-31", interval="1d")
    print(aapl_historical)
    outPutPath = os.path.join(base_dir, name + ".csv")
    aapl_historical.to_csv(outPutPath)
    print("_____End Processing" + name + "_____")


name = [] 
for i in range(570):
    start = 0
    name = ticker_pd["0"][start+i]
    suffix = settlement_pd["0"][start+i]
    if (suffix != "Luxembourg Stock Exchange"):
        suffix_last = settlement_msp[suffix]
        name = "-".join(name.split(" ")) + suffix_last
        if (not os.path.isfile(os.path.join(base_dir, name + ".csv"))):
            #print(name)
            getHistoricalData(name)

## for eachName in name
## getHistoricalData(name)


