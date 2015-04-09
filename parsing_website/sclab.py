from scipy.io import loadmat
import pickle,pdb

sc = loadmat('./mat/scene_detail')['scene_label']
st = loadmat('./mat/scene_type')['scene_type'] 
# 1 : birdseye view 2:Close up 3 inninng 4.steady cam 
stoffset = 3
#ondeck = loadmat('./mat/ondeck_box_detect_SVM_Model')['predicted_label']
deckseg = loadmat('./mat/ondeckSeg.mat')['ondeckSeg']
scPos = loadmat('./mat/scPos_Corr.mat')['scPos']
record = pickle.load(open('./mat/record.pkl','rb'))

rec  = record['All record']
Arec = record['Away record']
Hrec = record['Home record']

Alineup = record['Away lineup']
Hlineup = record['Home lineup']
Apic = record['Away pitcher']
Hpic = record['Home pitcher']

Ahrec = record['Away hitter']
Hhrec = record['Home hitter']
Aprec = record['Away pictcher']
Hprec = record['Home pictcher']
Asub = record['Away substitution']
Hsub = record['Home substitution']

abbrev = record['Name abbreviation']

bdescr = record['Batting describe']
pdescr = record['pitching describe']
fdescr = record['fileding describe']

def Tseg(fnum,per = 2):
    ts = ceil(fnum/30.).astype(int)
    te = ts+5
    result = ''
    h = ts/3600
    ts -= h*3600
    result += str(h)
    result += ':'
    m = ts/60
    ts -= m*60
    result += str(m)
    result += ':'
    result += str(ts)
    
    result += ','

    h = te/3600
    te -= h*3600
    result += str(h)
    result += ':'
    m = te/60
    te -= m*60
    result += str(m)
    result += ':'
    result += str(te)
    result += '  '

    return result



s,_ = sc.shape

text_file = open("sc.txt", "wb")
dsidx = 0


for i in range(s):

    if sc[i,1] !=0:  # has box or not
        inn = sc[i,3]
        out = sc[i,4]
        strike = sc[i,8]
        ball  = sc[i,9]
        bcnt  = sc[i,5]+sc[i,6]+sc[i,7] #how many people on base
        binfo = ''
        base = ['1','2','3']
        for j in [5,6,7]:  # check base info
            if sc[i,j] == 1:
                binfo = binfo + base[j-5]
            else:
                binfo = binfo + '-'

        candidate = []

        try : 
            sType = st[(st.T[0]==(scPos[sc[i,0]][0]+stoffset)).T][0][2]
            # 1 : birdseye view 2:Close up 3 inninng 4.steady cam
            Ss = st[(st.T[0]==(scPos[sc[i,0]][0]+stoffset)).T][0][0] #segment start                                                  
            Se = st[(st.T[0]==(scPos[sc[i,0]][0]+stoffset)).T][0][1] #segment end
        except:
            sType = 0  # segment too short
            Ss = scPos[sc[i,0]][0]
            try:
                Se = scPos[sc[i+1,0]][0]-1
            except:
                Se = Ss
        
        try :
            if (Ss<deckseg[dsidx][0]) & (Se>deckseg[dsidx][0]):
                deck = 1
            else:
                deck = 0
        except : 
            deck = 0   

        if sc[i,2] == 1 : 
        #up inn # away team hit home team defense
            
            for j in Arec[inn].keys():
                if ((Arec[inn][j][-2] == str(out)) & (Arec[inn][j][4] == binfo)):
                    candidate.append(j)
            if len(candidate) == 0:
                print('error happen in sence {0}'.format(i))
            elif len(candidate)>1:    
                print('multiple choice in sence {0}'.format(i))
            
            else:
                batter = abbrev[Arec[inn][candidate[0]][1]]
                pitcher = abbrev[Arec[inn][candidate[0]][0]]    
                brec = Ahrec[batter][1:] 
                prec = Hprec[pitcher][0:3:2]
            
                tstp   = Tseg(scPos[i][0]) #time stamp
                string = ''

                if sType == 0 : #segment too short
                    pass #do nothing

                elif sType == 1 or sType == 3 : #birdseye view or inning view
                    if binfo != '---':
                        string = string+'\n\n\n'+tstp+'Man on Base'
                        if '1' in binfo:
                            string = string+'\n'+tstp+'First Base : '+Arec[inn][candidate[0]][5][0]
                        if '2' in binfo:
                            string = string+'\n'+tstp+'Second Base : '+Arec[inn][candidate[0]][5][1]
                        if '3' in binfo:
                            string = string+'\n'+tstp+'Third Base : '+Arec[inn][candidate[0]][5][2]

                elif sType ==2: #Close up
                    string = tstp+bdescr[batter+' details'].replace('\n','\n'+tstp)+'\n\n\n'+\
                             tstp+pdescr[pitcher+' details'].replace('\n','\n'+tstp)
                else : #steady cam
                    string = tstp+bdescr[batter].replace('\n','\n'+tstp)+'\n\n\n'+\
                             tstp+pdescr[pitcher].replace('\n','\n'+tstp)



                #text_file.write(string)


        elif sc[i,2] == 2: 
        #bottom inn # home team hit away team defense
            
            for j in Hrec[inn].keys():
                if ((Hrec[inn][j][-2] == str(out)) & (Hrec[inn][j][4] == binfo)):
                    candidate.append(j)
            if len(candidate) == 0:
                print('error happen in sence {0}'.format(i))
            elif len(candidate)>1:
                print('multiple choice in sence {0}'.format(i))

            else:
                batter = abbrev[Hrec[inn][candidate[0]][1]]
                pitcher = abbrev[Hrec[inn][candidate[0]][0]]
                brec = Hhrec[batter][1:]
                prec = Aprec[pitcher][0:3:2]

                if sType == 0 :#segment too short                                                                                    
                    pass #do nothing 

                elif sType == 1 or sType == 3 : #birdseye view                                                                       
                    if binfo != '---':
                        string = string+'\n\n\n'+tstp+'Man on Base'
                        if '1' in binfo:
                            string = string+'\n'+tstp+'First Base : '+Hrec[inn][candidate[0]][5][0]
                        if '2' in binfo:
                            string = string+'\n'+tstp+'Second Base : '+Hrec[inn][candidate[0]][5][1]
                        if '3' in binfo:
                            string = string+'\n'+tstp+'Third Base : '+Hrec[inn][candidate[0]][5][2]

                elif sType ==2: #Close up                                                                                      
                    string = tstp+bdescr[batter+' details'].replace('\n','\n'+tstp)+'\n\n\n'+\
                             tstp+pdescr[pitcher+' details'].replace('\n','\n'+tstp)
                else: #steady cam                                                                                                   
                    string = tstp+bdescr[batter].replace('\n','\n'+tstp)+'\n\n\n'+\
                             tstp+pdescr[pitcher].replace('\n','\n'+tstp)


                #text_file.write(string)


        else:
            print('error happen in sence {0}'.format(i))

    
        if deck == 1:
            #pdb.set_trace()
            tstp   = Tseg(deckseg[dsidx][0],2)
            dsidx +=1
            try:                                                                                                                     
                batter = abbrev[Arec[inn][candidate[0]+1][1]]                                                                
            except:                                                                                                                  
                bidx = ([idx for idx,i in enumerate(Alineup) if 'Matt Carpenter' in i][0]+1)%9                               
                batter = Alineup[bidx][0]                                                                                    
            string = tstp+bdescr[batter+' details'].replace('\n','\n'+tstp)+'\n\n\n'


        string = string+'\n\n'   
        text_file.write(string)

text_file.close()
