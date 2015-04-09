# -*- coding: utf-8 -*-
"""
Created on Tue Mar 24 21:25:04 2015
@author: Dawnknight
"""
from bs4 import BeautifulSoup
import urllib2,pickle
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
#data type :  [pitcher,batter,result,score,  baseinfo, men on base ,out  ,pitchinfo]
#data idx  :  [  8       7       -1 ,   1     ,  3    ,    3       ,2    ,4    ]
infoidx = [8,7,-1,1,3,2,4] 
Hrec = {}  # home team record  
Arec = {}  # away team record
rec  = {}  # mix record
rectmp = {}



inn  = 1   # inning idx
half = 0   # top(0) and bottom(0) switch
No   = 1

outphrase = ['out','flayball','popfly','double play','triple play']

for i in range(len(box)):

    print('parsing game record .... {0:.02f}%\r'.format((i+1)*100/len(box))),
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
        rec[inn+np.mod(half,2)*0.5] = rectmp
        if np.mod(half,2) == 0:
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
        if j == 3: # check men on base infomation
           basestatus = re.findall("[1-9]",info[j].text.encode('ascii','ignore'))
           
           if  basestatus !=[]:
               runner = []
               urlbase = info[j].find('span').get('onclick').split('\'')[1]   
               ID = info[j].find('span').get('id')
               popurl = 'http://www.baseball-reference.com'+urlbase+ID
               reqbase = urllib2.Request(popurl)
               resbase  = urllib2.urlopen(reqbase)
               bodybase  = resbase .read()
               soupbase  = BeautifulSoup(bodybase)        
               baseinfo = soupbase.findAll('span',{'class':'highlight_text'})
               for k in ['2','3','1']:
                   if k in basestatus:
                       runner.append(baseinfo[['2','3','1'].index(k)].text.encode('ascii','ignore'))
                   else:
                       runner.append('_')
               runner = [runner[-1],runner[0],runner[1]]
           else:
              runner = ['_','_','_']  
             
        
           rectmp[No].append(info[j].text.encode('ascii','ignore'))     
           rectmp[No].append(runner)     
                
        elif j == 4 :
            rectmp[No].append(info[j].text.encode('ascii','ignore').split(')')[1])
            
        else: 
            rectmp[No].append(info[j].text.encode('ascii','ignore'))
            
    No +=1   

########### EXtract record initial setting  ##################################################### 

# catch line up and other players info
# batting  info idx
biidx = [ 1  , 4  , 17 , 8, 11  ,12  ,21 , 29    ,  18 , 19  , 20 ]
#      [age , G  , BA , H, HR  ,RBI ,ops+, award , OBP , SLG , OPS]
#      [0     1     2   3   4    5    6      7      8     9     10]
#pitching info idx
piidx = [  1 , 8 ,  9 , 14 , 4 , 5 ,  7  , 12 , 13 , 26   , 28   , 29, 31  ,32 , 33 , 34]
#      [age , G , GS , IP , W , L , ERA , SHO, SV , ERA+ , WHIP , H9, BB9 ,SO9,K/BB, special Award]
#      [ 0    1    2    3   4   5    6     7    8    9      10    11   12   13   14     15        ]
#fild info idx
fiidx = [8   , 9 , 12 , 14] 
#       [inn , ch,  E , fid]
#       [0      1   2    3 ]

bdescr = {}  # batting description
pdescr = {}  # pitching description
fdescr = {}  # fielding description


abbrev = {}

################  Extract away team record ##################
print('\n')

Aplayers = soup.find('div',id = 'all_StLouisCardinalsbatting').\
                find('tbody').findAll('tr',{'class':'normal_text'})

Type = 0  # 0 for batting, 1 for pitcher\

Alineup = []
Apitch = []
Asub = []

Aprec     = {}  # away team pitches record
Ahrec     = {}  # away team hitters record
sp = 0          # index for checking the starting pitcher

for pidx,pinfo in enumerate(Aplayers):
    
    print('Extract away team record .... {0:.02f}%\r'.format((pidx+1)*100/len(Aplayers))),
    sys.stdout.flush

    name , pos = pinfo.find('td',align = 'left').text.encode('ascii','ignore').split('  ') 
    purl = 'http://www.baseball-reference.com' + pinfo.find('td',align = 'left').find('a').get('href')

    if (pos != 'P'):
        Type = 0
        if (u'\xa0' not in pinfo.find('td',align = 'left').text):
            Alineup.append([name,pos])
        else:
            Asub.append([name,pos])
    else:
        Type = 1
        if sp ==0:
            pos = 'SP'
            sp = 1
        Apitch.append([name,pos])


    preq = urllib2.Request(purl)
    pres = urllib2.urlopen(preq)
    pbody = pres.read()
    psoup = BeautifulSoup(pbody)
    playerb = []
    playerf = []
    playerp = []
    overall = [] 



    #batting record
    try : 
        bREC= psoup.find('div',{'class':'stw div_batting_type'}).tbody.\
                    find('tr',id = 'batting_standard.2013').findAll('td')
        for i in biidx:
            playerb.append(bREC[i].text.encode('ascii','ignore'))
    except:
        pass

    #pitching record
    try:
        pREC = psoup.find('div',id = 'div_pitching_standard').tbody.\
                     find('tr',id = 'pitching_standard.2013').findAll('td')
        for i in piidx:
            playerp.append(pREC[i].text.encode('ascii','ignore'))
    except:
        pass

    #fileding record
    fREC = psoup.find('div',{'class':'stw div_fielding_type show_always'}).tbody.\
                 findAll('tr',id = '2013:standard_fielding')
    
    for f in fREC:
        if (f.findAll('td')[4].text.encode('ascii','ignore') == pos) or (pos == 'SP'):
            finfo = f.findAll('td')
            for i in fiidx:
                playerf.append(finfo[i].text.encode('ascii','ignore'))
            break

    overall.append(playerp)
    overall.append(playerb)
    overall.append(playerf)

    fdescr[name] = 'Fileding Record of {0}({1})\nInn : {2}  Chances : {3} \nError : {4}  Fid : {5}\n'\
                   .format(name,pos,playerf[0],playerf[1],playerf[2],playerf[3])

    if playerb != []:
        bdescr[name] ='Batting Record of {0}\nGame : {1}  AVG : {2} \nH : {3} HR : {4} RBI : {5}\n'\
                      .format(name,playerb[1],playerb[2],playerb[3],playerb[4],playerb[5])
        bdescr[name+' details'] ='Batting Record of {0}\nGame : {1}  AVG : {2} \nH : {3} HR : {4} RBI : {5}\n'\
                                 .format(name,playerb[1],playerb[2],playerb[3],playerb[4],playerb[5])+\
                                 'OBP : {0} SLG : {1} \nOPS : {2}  OPS+ : {3}\nAward in 2013: {4}\n'\
                                 .format(playerb[8],playerb[9],playerb[10],playerb[6],playerb[7])

    if playerp != []:
        if pos == 'P':
           pdescr[name] ='Pitching Record of {0}\nGame : {1} IP : {2} SHO : {3} \nSV :{4} ERA :{5} Whip : {6}\n'\
                         .format(name,playerp[1],playerp[3],playerp[7],playerp[8],playerp[6],playerp[10])

           pdescr[name+' details'] ='Pitching Record of {0}\nGame : {1} IP : {2} SHO : {3} \nSV :{4} ERA :{5} Whip : {6}\n'\
                                    .format(name,playerp[1],playerp[3],playerp[7],playerp[8],playerp[6],playerp[10])+\
                                    'H9 : {0}  BB9 : {1}\nK9 : {2}  K/BB : {3}\nAward in 2013: {4}'\
                                    .format(playerp[11],playerp[12],playerp[13],playerp[14],playerp[15])

        elif pos == 'SP':
            pdescr[name] ='Pitching Record of {0}\nGame(GS) : {1}({2}) IP : {3}  \nERA :{4} Whip : {5}\n'\
                          .format(name,playerp[1],playerp[2],playerp[3],playerp[6],playerp[10])
            pdescr[name+' details'] ='Pitching Record of {0}\nGame(GS) : {1}({2}) IP : {3}  \nERA :{4} Whip : {5}\n'\
                                     .format(name,playerp[1],playerp[2],playerp[3],playerp[6],playerp[10])+\
                                     'H9 : {0}  BB9 : {1}\nK9 : {2}  K/BB : {3}\nAward in 2013: {4}'\
                                     .format(playerp[11],playerp[12],playerp[13],playerp[14],playerp[15])
        else:
            pdescr[name] ='Pitching Record of {0}\nGame : {1} IP : {2}  ERA :{3} Whip : {4}\n'\
                          .format(name,playerp[1],playerp[3],playerp[6],playerp[10])
            pdescr[name+' details']= 'Pitching Record of {0}\nGame : {1} IP : {2}  ERA :{3} Whip : {4}\n'\
                                     .format(name,playerp[1],playerp[3],playerp[6],playerp[10])


        
    if Type == 1 : # pitcher
        Aprec[name] = overall
    else:
        Ahrec[name] = overall

    abbrev[name[0]+'.'+name.split(' ')[-1]] = name    


########  Extract home team player record  ##########
print('\n')

Hplayers = soup.find('div',id = 'div_BostonRedSoxbatting').\
                find('tbody').findAll('tr',{'class':'normal_text'})

Type = 0  # 0 for batting, 1 for pitcher                                                                                   

Hlineup = []
Hpitch = []
Hsub = []


Hprec     = {}  # away team pitches record
Hhrec     = {}  # away team hitters record                                                                                                                      
sp = 0


for hidx,pinfo in enumerate(Hplayers):

    print('Extract home team player record.... {0:.02f}%\r'.format((hidx+1)*100/len(Hplayers))),
    sys.stdout.flush

    name , pos = pinfo.find('td',align = 'left').text.encode('ascii','ignore').split('  ')
    purl = 'http://www.baseball-reference.com' + pinfo.find('td',align = 'left').find('a').get('href')

    if (pos != 'P'):
        Type = 0
        if (u'\xa0' not in pinfo.find('td',align = 'left').text):
            Hlineup.append([name,pos])
        else:
            Hsub.append([name,pos])
    else:
        Type = 1
        if sp ==0:
            pos = 'SP'
            sp = 1
        Hpitch.append([name,pos])


    preq = urllib2.Request(purl)
    pres = urllib2.urlopen(preq)
    pbody = pres.read()
    psoup = BeautifulSoup(pbody)
    playerb = []
    playerf = []
    playerp = []
    overall = []



    #batting record                                                                                                                                             
    try :
        bREC= psoup.find('div',{'class':'stw div_batting_type'}).tbody.\
                    find('tr',id = 'batting_standard.2013').findAll('td')
        for i in biidx:
            playerb.append(bREC[i].text.encode('ascii','ignore'))
    except:
        pass

    #pitching record                                                                                                                                            
    try:
        pREC = psoup.find('div',id = 'div_pitching_standard').tbody.\
                     find('tr',id = 'pitching_standard.2013').findAll('td')
        for i in piidx:
            playerp.append(pREC[i].text.encode('ascii','ignore'))
    except:
        pass

    #fileding record                                                                                                                                            
    fREC = psoup.find('div',{'class':'stw div_fielding_type show_always'}).tbody.\
                 findAll('tr',id = '2013:standard_fielding')

    for f in fREC:
        if (f.findAll('td')[4].text.encode('ascii','ignore') == pos) or (pos == 'SP'):
            finfo = f.findAll('td')
            for i in fiidx:
                playerf.append(finfo[i].text.encode('ascii','ignore'))
            break

    overall.append(playerp)
    overall.append(playerb)
    overall.append(playerf)


    fdescr[name] = 'Fileding Record of {0}({1})\nInn : {2}  Chances : {3} \nError : {4}  Fid : {5}\n'\
                   .format(name,pos,playerf[0],playerf[1],playerf[2],playerf[3])

    if playerb != []:
        bdescr[name] ='Batting Record of {0}\nGame : {1}   AVG : {2} \nH : {3} HR : {4} RBI : {5}\n'\
                      .format(name,playerb[1],playerb[2],playerb[3],playerb[4],playerb[5])
        bdescr[name+' details'] ='Batting Record of {0}\nGame : {1}   AVG : {2} \nH : {3} HR : {4} RBI : {5}\n'\
                                 .format(name,playerb[1],playerb[2],playerb[3],playerb[4],playerb[5])+\
                                 'OBP : {0} SLG : {1} \nOPS : {2}  OPS+ : {3}\nAward in 2013: {4}\n'\
                                 .format(playerb[8],playerb[9],playerb[10],playerb[6],playerb[7])

    if playerp != []:
        if pos == 'P':
           pdescr[name] ='Pitching Record of {0}\nGame : {1} IP : {2} SHO : {3} \nSV :{4} ERA :{5} Whip : {6}\n'\
                         .format(name,playerp[1],playerp[3],playerp[7],playerp[8],playerp[6],playerp[10])

           pdescr[name+' details'] ='Pitching Record of {0}\nGame : {1} IP : {2} SHO : {3} \nSV :{4} ERA :{5} Whip : {6}\n'\
                                    .format(name,playerp[1],playerp[3],playerp[7],playerp[8],playerp[6],playerp[10])+\
                                    'H9 : {0}  BB9 : {1}\nK9 : {2}  K/BB : {3}\nAward  in 2013: {4}'\
                                    .format(playerp[11],playerp[12],playerp[13],playerp[14],playerp[15])

        elif pos == 'SP':
            pdescr[name] ='Pitching Record of {0}\nGame(GS) : {1}({2})    IP : {3}  \nERA :{4}    Whip : {5}\n'\
                         .format(name,playerp[1],playerp[2],playerp[3],playerp[6],playerp[10])
            pdescr[name+' details'] ='Pitching Record of {0}\nGame(GS) : {1}({2})    IP : {3}  \nERA :{4}    Whip : {5}\n'\
                                     .format(name,playerp[1],playerp[2],playerp[3],playerp[6],playerp[10])+\
                                     'H9 : {0}  BB9 : {1}\nK9 : {2}  K/BB : {3}\nAward  in 2013: {4}'\
                                     .format(playerp[11],playerp[12],playerp[13],playerp[14],playerp[15])
        else:
            pdescr[name] ='Pitching Record of {0}\nGame : {1} IP : {2}  ERA :{3} Whip : {4}\n'\
                          .format(name,playerp[1],playerp[3],playerp[6],playerp[10])
            pdescr[name+' details']= 'Pitching Record of {0}\nGame : {1} IP : {2}  ERA :{3} Whip : {4}\n'\
                                     .format(name,playerp[1],playerp[3],playerp[6],playerp[10])



    if Type == 1 : # pitcher                                                                                                                                    
        Hprec[name] = overall
    else:
        Hhrec[name] = overall


    abbrev[name[0]+'.'+name.split(' ')[-1]] = name


# save the data

print('export the data ....')

ALLRecord = {}

ALLRecord['All record']        = rec
ALLRecord['Away record']       = Arec
ALLRecord['Home record']       =Hrec
ALLRecord['Away lineup']       =Alineup
ALLRecord['Home lineup']       =Hlineup
ALLRecord['Away pitcher']      =Apitch
ALLRecord['Home pitcher']      =Hpitch
ALLRecord['Away hitter']       =Ahrec
ALLRecord['Home hitter']       =Hhrec
ALLRecord['Away pictcher']     =Aprec
ALLRecord['Home pictcher']     =Hprec
ALLRecord['Away substitution'] =Asub
ALLRecord['Home substitution'] =Hsub
ALLRecord['Name abbreviation'] =abbrev
ALLRecord['Batting describe']  =bdescr
ALLRecord['pitching describe'] =pdescr
ALLRecord['fileding describe'] =fdescr

pickle.dump(ALLRecord,open('mat/record.pkl','wb'),True)
 
