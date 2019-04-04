# -*- coding: utf-8 -*-
"""
Created on Wed Mar 13 23:43:08 2019

@author: t-aygupt
"""

import seaborn as sns
import pandas as pd
import numpy as np
import math
from sklearn.neighbors import NearestNeighbors
import matplotlib.pyplot as plt
import operator
from PIL import Image
import sys
import webcolors as wb
knn=50

from sklearn import preprocessing
from sklearn.preprocessing import StandardScaler,MinMaxScaler

import  heidiHelper as hh
import orderPoints as op
from PIL import Image, ImageOps

allcolors = [[51,98,107],  [240,74,28],  [219,65,226],  [72,198,33],  [96,56,90],  [62,86,23],  [112,146,236],  [241,63,122],  [190,169,39],  [118,54,14],  [217,155,187],  [71,190,192],  [227,147,102],  [118,180,101],  [159,47,132],  [216,133,224],  [107,78,181],  [174,37,43],  [73,98,152],  [232,127,43],  [194,103,105],  [97,177,216],  [170,121,34],  [163,165,86],  [56,103,72],  [54,158,43],  [86,59,28],  [224,57,163],  [177,95,231],  [232,102,155],  [95,188,156],  [156,91,152],  [117,45,66],  [114,119,28],  [161,69,179],  [69,69,86],  [167,110,81],  [150,167,219],  [131,47,44],  [62,143,155],  [128,106,143],  [234,93,83],  [230,100,220],  [191,153,224],  [195,154,89],  [99,85,21],  [228,157,51],  [169,54,77],  [73,62,122],  [193,98,71],  [115,43,104],  [131,112,234],  [125,195,50],  [188,48,20],  [222,53,85],  [168,51,109],  [99,128,154],  [134,157,43],  [46,107,25],  [226,105,185],  [70,192,134],  [174,114,139],  [134,180,193],  [75,149,213],  [70,187,98],  [232,47,190],  [236,60,58],  [34,74,67],  [158,110,200],  [232,102,119],  [59,132,121],  [66,111,214],  [78,128,73],  [233,44,138],  [128,120,61],  [149,94,36],  [166,145,190],  [96,105,180],  [88,159,115],  [50,76,111],  [218,125,167],  [238,142,139],  [186,50,166],  [94,64,146],  [169,185,45],  [155,61,26],  [115,62,44],  [69,74,32],  [200,161,68],  [209,99,43],  [151,80,97],  [95,135,50],  [105,165,49],  [237,122,97],  [37,77,33],  [161,186,94],  [64,206,71],  [122,80,102],  [202,44,105],  [115,82,40]  ];


class subspaceImage:
    
    def __init__(self):
        self.inputData=pd.DataFrame([])
        self.columnnames=[]
        self.classLabel=''
        self.knn=20
        self.allsubspaces=[]
        self.nofdims=0
        self.subspaceColors={} #key is subspace as tuple and value is rgb color as list {tuple:list} {subspace:rgb}
    
    def setDataset(self,inputData,classLabel):
        self.inputData=inputData
        self.classLabel=classLabel
        self.inputData['id']=self.inputData.index
        self.inputData.index = self.inputData['id']
        del self.inputData['id']
        self.nofdims=self.inputData.shape[1]
        self.columnnames=list(inputData.columns)
        #print(inputData)
        print(self.nofdims)
        
    def setKNN(self,knn):
        self.knn=knn
    
    def setAllSubspaces(self):
        max_count=int(math.pow(2,self.nofdims))
        allsubspaces=range(1,max_count)
        f=lambda a:sorted(a,key=lambda x:sum(int(d)for d in bin(x)[2:]))
        allsubspaces=f(allsubspaces)
        
        frmt=str(self.nofdims)+'b'
        for i in allsubspaces:
            bin_value=str(format(i,frmt))
            bin_value=bin_value[::-1]
            subspace_col=[index for index,value in enumerate(bin_value) if value=='1']
            self.allsubspaces.append(tuple(subspace_col))
        
    def setProminentSubspaces(self,subspaceList):
        subspaceList1=[]
        for i in subspaceList:
            subspaceList1.append([index for index,value in enumerate(i) if value==True])
        max_count=int(math.pow(2,self.nofdims))
        allsubspaces=range(1,max_count)
        f=lambda a:sorted(a,key=lambda x:sum(int(d)for d in bin(x)[2:]))
        allsubspaces=f(allsubspaces)
        
        frmt=str(self.nofdims)+'b'
        for i in allsubspaces:
            bin_value=str(format(i,frmt))
            bin_value=bin_value[::-1]
            subspace_col=[index for index,value in enumerate(bin_value) if value=='1']
            if(subspace_col in subspaceList1):
                self.allsubspaces.append(subspace_col)
    
    def printAllsubspaces(self):
        for i in self.allsubspaces:
            print(i)
    
    def printColorToEachSubspace(self):
        for i in self.subspaceColors:
            print(i,':', self.subspaceColors[i])

    def giveColorToEachSubspace(self):
        c=0
        global allcolors
        for i in self.allsubspaces:
            self.subspaceColors[tuple(i)]=allcolors[c]
            c=c+1

    def orderPoints(self):
        temp = self.inputData.copy()
        temp['classLabel']=self.classLabel.values
        temp['classLabel_orig'] = self.classLabel.values
        sorted_data = op.sortbasedOnclassLabel(temp,'knn_bfs')
        
        sorting_order = sorted_data.index
        self.inputData = self.inputData.reindex(sorting_order)
        self.classLabel = self.classLabel.reindex(sorting_order)
        self.inputData.to_csv('orderedfile.csv')
        return

    def getHeidiImageForSubspace(self, subspace, outputpath):
        row=self.inputData.shape[0]
        heidi_matrix=np.zeros(shape=(row,row),dtype=np.uint64)
        subspace_col = [i for i,x in enumerate(subspace) if x]
        filtered_data=self.inputData.iloc[:,subspace_col] 
        np_subspace=filtered_data.values
        nbrs=NearestNeighbors(n_neighbors=knn,algorithm='ball_tree').fit(np_subspace)
        temp=nbrs.kneighbors_graph(np_subspace).toarray()
        temp=temp.astype(np.uint64)
        heidi_matrix=temp
        arr = np.zeros((heidi_matrix.shape[0],heidi_matrix.shape[1],3))
        for i in range(heidi_matrix.shape[0]):
            for j in range(heidi_matrix.shape[1]):
                if(heidi_matrix[i][j]==1):
                    arr[i][j]= self.subspaceColors[tuple(subspace_col)]
                else:
                    arr[i][j]=[255,255,255]
                    
        tmp = arr.astype(np.uint8)
        img = Image.fromarray(tmp)
        img.save(outputpath)
        return
    
    def getHeidiImagesForAllSubspaces(self):
        opath=[]
        hm=[]
        c=0
        for subspace_col in self.allsubspaces:
            row=self.inputData.shape[0]
            heidi_matrix=np.zeros(shape=(row,row),dtype=np.uint64)
            print(subspace_col)
            filtered_data=self.inputData.iloc[:,list(subspace_col)] 
            np_subspace=filtered_data.values
            nbrs=NearestNeighbors(n_neighbors=knn,algorithm='ball_tree').fit(np_subspace)
            temp=nbrs.kneighbors_graph(np_subspace).toarray()
            temp=temp.astype(np.uint64)
            heidi_matrix=temp
            hm.append(heidi_matrix)
            arr = np.zeros((heidi_matrix.shape[0],heidi_matrix.shape[1],3))
            for i in range(heidi_matrix.shape[0]):
                for j in range(heidi_matrix.shape[1]):
                    if(heidi_matrix[i][j]==1):
                        arr[i][j]= self.subspaceColors[subspace_col]
                    else:
                        arr[i][j]=[255,255,255]
            tmp = arr.astype(np.uint8)
            img = Image.fromarray(tmp)
            img.save('./img_noborder'+str(c)+'.png')
            img_with_border = ImageOps.expand(img,border=2, fill='black')
            img_with_border.save('./img_'+str(c)+'.png')
            opath.append('./img_'+str(c)+'.png')
            c=c+1
            
        return opath,hm
    
    def createLegend(self, output_fname='legend.html'):
        print(self.columnnames)
        html_str='<table border=1>\n'
        html_str+='<tr><td><b>Color</b></td><td><b>Set of subspaces</b></td><td>select</td></tr>\n'
        for val in self.subspaceColors:
            rgb=self.subspaceColors[val]
            r=rgb[0]
            g=rgb[1]
            b=rgb[2]
            subspace=[]
            for dim in val:
                subspace.append(self.columnnames[dim])
            html_str+=("<tr><td bgcolor=#%2x%2x%2x class='backgroundcolor'></td><td>%s</td><td><input type='checkbox' name='color' value='#%2x%2x%2x'></td></tr>" %(r,g,b,str(subspace),r,g,b))
        html_str+='</table>'
        Html_file= open(output_fname,"w")
        Html_file.write(html_str)
        Html_file.close()
        
def subspaceImageHelper(inputData,classLabel):
    obj = subspaceImage()
    #print(inputData.shape, classLabel.shape)
    obj.setDataset(inputData,classLabel)
    obj.orderPoints()
    obj.setAllSubspaces()
    obj.giveColorToEachSubspace()
    #obj.printAllsubspaces()
    obj.createLegend()
    allImages = obj.getHeidiImagesForAllSubspaces()
    print('----returned-----')
    return allImages
    #return NULL



def add(x, y,df):
  print('hello')
  print(df,x,y)
  return x + y

'''
if __name__=='__main__':
    df = pd.read_csv('C:\\Users\\t-aygupt\\Desktop\\uploads\\iris.csv')
    df.index=df['id']
    del df['id']
    obj = subspaceImage()
    obj.setDataset(df.iloc[:,:-1],df.iloc[:,-1])
    obj.setAllSubspaces()
    #subspaceList=[[True,False,True,True], [False,False,True,True], [True,True,True,True], [True,False,False,True], [True,False,True,False]]
    #obj.setProminentSubspaces(subspaceList)
    obj.printAllsubspaces()
    obj.giveColorToEachSubspace()
    obj.printColorToEachSubspace()
    obj.createLegend()
    allImages = obj.getHeidiImagesForAllSubspaces()
    print(allImages)
    c=0
    #for i in subspaceList:
    #    opath='C:\\Users\\t-aygupt\\Documents\\GitHub\\subspaceVis\\temp'+str(c)+'.jpeg'
    #    img = obj.getHeidiImageForSubspace(i,opath) 
    #    c=c+1
'''