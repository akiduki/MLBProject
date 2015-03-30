# -*- coding: utf-8 -*-
"""
Created on Tue Mar 24 21:25:04 2015

@author: Dawnknight
"""
from bs4 import BeautifulSoup
import urllib2
import sys,csv,re,pdb
import numpy as np
url = 'http://www.baseball-reference.com/boxes/BOS/BOS201310300.shtml/'
req = urllib2.Request(url)
res = urllib2.urlopen(req)
body = res.read()
soup = BeautifulSoup(body)
box = soup.find('table',id = 'play_by_play').find('tbody').findAll('tr')
innstart = {}
innsidx  = []
innend   = {}
inneidx  = []
sub      = {}
subidx   = []


#### record
#data type :  [pitcher,batter,score,baseinfo,out,result]
#data idx  :  [  8       7      1       3     2    -1  ]
infoidx = [8,7,1,3,2,-1] 
Hrec = {}  # home team record  
Arec = {}  # away team record
rec  = {}  # mix record
rectmp = {}



inn  = 1   # inning idx
half = 0   # top(0) and bottom(0) switch
No   = 1

outphrase = ['out','flayball','popfly','double play','triple play']


for i in range(len(box)):

    print('parsing .... {0:.02f}%\r'.format((i+1)*100/len(box))),
    sys.stdout.flush()

    tag = box[i]

    # inning start tag
    try:
        tag.find('span',{'class':'half_inning_start'}).text.encode('ascii','ignore')
        innsidx.append(i)
        continue 
    except:
        pass

    # inning end tag   
    try:
        tag.find('span',{'class':'half_inning_summary'}).text.encode('ascii','ignore')
        inneidx.append(i)
        rec[inn+mod(half,2)*0.5] = rectmp
        if mod(half,2) == 0:
            Arec[inn] = rectmp
        else:
            Hrec[inn] =rectmp
            inn  += 1


        rectmp = {}
        No = 1
        half += 1 
        continue
    except:
        pass
        
    # in game substitution tag    
    try:
        tag.find('span',{'class':'subst'}).text.encode('ascii','ignore')
        subidx.append(i)
        continue
    except:
        pass
        
    
    info = tag.findAll('td')
    rectmp[No]= []
    for j in infoidx:
        rectmp[No].append(info[j].text.encode('ascii','ignore'))
    No +=1   



############################
'''
parsing pop up windows ....

main = 'http://www.baseball-reference.com'
url2 = tag.find('span').get('onclick').split('\'')[1]
id = tag.find('span').get('id')
popurl = main+url2+id



'''
