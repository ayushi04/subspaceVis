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

def generateHeidiMatrixResults_noorder(inputData,k=20):
    factor=1
    knn=k
    bit_subspace={}
    row=inputData.shape[0]
    count=0
    heidi_matrix=np.zeros(shape=(row,row),dtype=np.uint64)
    max_count=int(math.pow(2,inputData.shape[1]-1))
    allsubspaces=range(1,max_count)
    f=lambda a:sorted(a,key=lambda x:sum(int(d)for d in bin(x)[2:]))
    allsubspaces=f(allsubspaces)
    #print(allsubspaces)
    frmt=str(inputData.shape[1]-1)+'b'
    factor=1
    bit_subspace={}
    count=0
    #print('knn:',knn)

    for i in allsubspaces:
        bin_value=str(format(i,frmt))
        bin_value=bin_value[::-1]
        subspace_col=[index for index,value in enumerate(bin_value) if value=='1']

        filtered_data=inputData.iloc[:,subspace_col+[-1]] #NEED TO CHANGE IF COL IS A LIST
        filtered_data['classLabel_orig']=filtered_data['classLabel'].values
        sorted_data=filtered_data
        subspace=sorted_data.iloc[:,:-2]
        np_subspace=subspace.values#NEED TO CHANGE IF COL IS A LIST
        #print(np_subspace.shape)
        nbrs=NearestNeighbors(n_neighbors=knn,algorithm='ball_tree').fit(np_subspace)
        temp=nbrs.kneighbors_graph(np_subspace).toarray()
        temp=temp.astype(np.uint64)
        heidi_matrix=heidi_matrix + temp*factor
        factor=factor*2
        subspace_col_name=[inputData.columns[j] for j in subspace_col]
        #print(i,subspace_col_name)
        bit_subspace[count]=subspace_col_name
        count+=1
    return heidi_matrix,bit_subspace,sorted_data

def generateHeidiMatrixResults_noorder_helper(heidi_matrix,bit_subspace,outputPath,sorted_data,legend_name,val_map={},mapping_dict={}):
    if(val_map=={}) : map_dict,all_info=hh.getMappingDict(heidi_matrix,bit_subspace)
    else:
        #map_dict,all_info=hh.getMappingDict(heidi_matrix,bit_subspace)
        map_dict,all_info=hh.getMappingDictClosedImg(heidi_matrix,bit_subspace,val_map,mapping_dict)

    #print(map_dict,all_info)
    
    hh.createLegend(map_dict,all_info,outputPath+'/'+legend_name+'.html')
    
    dict1=hh.dictForDatabase(map_dict,all_info)
    img,imgarray=hh.generateHeidiImage(heidi_matrix,map_dict)
    print('1-------------------------------------------------------')
    hh.saveHeidiImage(img,outputPath,'img_bea.png')
    print('2-------------------------------------------------------')
    array=sorted_data['classLabel'].values
    print('3-------------------------------------------------------')
    algo1_bar,t=hh.createBar(array)
    hh.visualizeConsolidatedImage(imgarray,algo1_bar,outputPath+'/consolidated_img.png')
    print('visualized consolidated image')
    
    return img,dict1


def orderPoints(filtered_data):
    #---------------2. ORDERING POINTS ----------------------------------------------
    dim = filtered_data.columns[:-1]
    dim=dim[1:]
    data = filtered_data.copy()
    filtered_data['classLabel_orig']=filtered_data['classLabel'].values
    # IF ORDERDIM LENGTH =1 THEN ORDERING BY SORTED ORDER ELSE SOME OTHER ORDERING SCHEMA
    print('dim',dim)
    if len(dim)==1:
        param={}
        param['columns']=list(filtered_data.columns[:-1])
        param['order']=[True for i in param['columns']]
        sorted_data=op.sortbasedOnclassLabel(filtered_data,'dimension',param)
        # REINDEXING THE INPUT DATA (TO BE USED LATER)
        sorting_order=sorted_data.index
        data=data.reindex(sorting_order)
    else:
        print('mst ordering')
        param={}
        sorted_data=op.sortbasedOnclassLabel(filtered_data,'knn_bfs',param)#'mst_distance' #connected_distance
        #sorted_data=op.sortbasedOnclassLabel(filtered_data,'euclidian_distance',param)
        sorting_order=sorted_data.index
        data=data.reindex(sorting_order)
    return data



def test_func(df):
    df = orderPoints(df)
    #print(df)
    matrix,bs,sorted_data = generateHeidiMatrixResults_noorder(df)
    output='.'
    img,bit_subspace=generateHeidiMatrixResults_noorder_helper(matrix,bs,output,sorted_data,'legend_heidi')
    return output+'/consolidated_img.png'


