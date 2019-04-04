import subspaceImage as si
import pandas as pd

df = pd.read_csv('/home/ayushi/Desktop/subspace-search/auto-mpg-7d-order.csv')
df['label']=1
df=df[['mpg','cylinders','displacement','label']]

obj = si.subspaceImage()
obj.setDataset(df.iloc[:,:-1],df.iloc[:,-1])
obj.setAllSubspaces()

obj.printAllsubspaces()
obj.giveColorToEachSubspace()
obj.printColorToEachSubspace()
obj.createLegend()
allImages,hm = obj.getHeidiImagesForAllSubspaces()

print(hm)