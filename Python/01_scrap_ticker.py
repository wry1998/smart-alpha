import bs4
from pyparsing import line
import requests
import numpy as np
import pandas as pd
headers = { ## access webpage
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Max-Age': '3600',
    'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0'
    }
ticker_list = []
settle_list = []
for i in range(19):
    url = r"https://www.dividendmax.com/market-index-constituents/stoxx600?page=" + str(i + 1)
    req = requests.get(url , headers)

    soup = bs4.BeautifulSoup(req.content, 'html.parser')


    lineCheck = 1
    for node in soup.find_all("td", {"class": 'mdc-data-table__cell'}):
    
        if (lineCheck % 6 == 2):
            ticker_list.append(''.join(node.findAll(text=True)))
        if (lineCheck % 6 == 4):
            settle_list.append(''.join(node.findAll(text=True)))
        lineCheck += 1

np_ticker = pd.DataFrame(ticker_list)
np_settle = pd.DataFrame(settle_list)
np_ticker.to_csv(r"...\data\ticker_list.csv")
np_settle.to_csv(r"...\data\settle_list.csv")