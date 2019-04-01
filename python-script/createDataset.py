import pandas as pd
from sklearn import datasets
from sklearn.preprocessing import StandardScaler

def createDataset(n_samples,dim=5,n_centres=3,type='synth_blobs'):
    if(type=='synth_blobs'):
        X,labels=datasets.make_blobs(n_samples=n_samples,n_features=dim,centers=n_centres, cluster_std=0.7,random_state=8)
    elif(type=='synth_circle'):
        X,labels=datasets.make_circles(n_samples=n_samples,factor=.5,noise=.05)
    elif(type=='synth_moon'):
        X,labels = datasets.make_moons(n_samples=n_samples, noise=.05)
    X=StandardScaler().fit_transform(X)
    X=pd.DataFrame(X)
    labels=pd.DataFrame(labels)
    return X,labels

if __name__=='__main__' :
    X,labels=createDataset(500,dim=6,n_centres=4,type='synth_blobs') #points, dim, nofclusters
    y=X.copy()
    y['classLabel']=labels
    y['id']=['p'+str(i) for i in y.index]
    y.index = y['id']
    del y['id']
    y.to_csv('C:\\Users\\t-aygupt\\Desktop\\uploads\\synth_6d_4c.csv',index=True);