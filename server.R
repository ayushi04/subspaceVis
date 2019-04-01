function(input,output) {
  
  #if no variables are selected, disable run button
  observe({
    if(is.null(input$vars) || input$vars=='') {
      shinyjs::disable(("action"))
    } else {
      shinyjs::enable("action")
    }
  })


# this piece of code hides and shows parallel coordinate and other plots based on variable selection
observe({
  if(is.null(input$vars) || input$vars == '') {
    shinyjs::show('parcoords')
    shinyjs::hide('parcoords2')
    shinyjs::hide('dendogram_subspace')
    shinyjs::hide('dendogram_top')
    shinyjs::hide("allplots")
  }
})

observeEvent(input$action, {
  shinyjs::hide("parcoords")
  shinyjs::show("parcoords2")
  shinyjs::show("dendogram_subspace")
  shinyjs::show("dendogram_top")
  shinyjs::show("allplots")
})

# read in the dataset, remove any rows with missing data
info <- reactive({
  infile <- input$file1
  if (is.null(infile)){
    return(NULL)      
  }
  t=read.table(infile$datapath, header = input$header, sep = input$sep)
  t=t[complete.cases(t),]
  return(t)
})


# show the variable names in the dataset for user selection
output$vars<- renderUI({
  df <- info()
  if (is.null(df)) return(NULL)
  items=names(df)
  names(items)=items
  selectInput("vars","Select variables",items, multiple = T,selected = NULL)
})

output$label<-renderUI({
  df <- info()
  if(is.null(df)) return(NULL)
  items = names(df)
  names(df) = items
  selectInput("label",'Select class Label', items, multiple=F)
})

output$id <-renderUI({
  df <- info()
  if(is.null(df)) return (NULL)
  items = names(df)
  names(df) = items
  selectInput('id','Select Id column', items ,multiple=F)
})

output$parcoords = renderParcoords({
  df <- info()
  if(is.null(df)) return(NULL)
  print('Displaying all columns in parallel coordinate plot')
  numeric_cols = unlist(lapply(df, is.numeric))
  parcoords(df[, numeric_cols],rownames=F, brushMode='1d')
})


#main part of app
models = eventReactive(input$action, {
  adata = info()
  adatause = adata[input$vars]
  adatalabel = adata[input$label]
  adataid = adata[input$id]
  #newdata = data.frame(adatause,adatalabel)
  allval = list(adata=adatause, label=adatalabel, id=adataid)
  return(allval)
})

output$parcoords2 = renderParcoords(({
  df <-  models()
  if(is.null(df)) return(NULL)
  print('Displaying selected columns in parallel coordinate Plot')
  a <- data.frame(df$adata,df$label)
  parcoords(a, rownames=F, brushMode='1d')
}))

tanimoto <- function(x, similarity=T) {
  res<-sapply(x, function(x1){
    sapply(x, function(x2) {i=length(which(x1 & x2))*100 / length(which(x1 | x2)); ifelse(is.na(i), 0, i)})
  })
  if(similarity==T) return(res)
  else return(1-res)
}

output$dendogram_subspace = renderPlot({
  df = models()
  if(is.null(df)) return(NULL)
  print('Displaying dendrogram based on dimension similarity of subspaces')
  ncols <- ncol(df$adata)
  nsubspace <- 2 ^ ncols - 1
  c=vector()
  df_subspace=data.frame(matrix(ncol=ncols, nrow=nsubspace))
  colnames(df_subspace) <- names(df$adata)
  for (i in 1:nsubspace) {
    df_subspace[i,] = as.binary(i, n = ncols)
    df_subspace[i,] = as.binary(i, n = ncols)
    t=names(df_subspace)
    
    x=as.numeric(df_subspace[i,])
    c[i]=paste(t[as.logical(x)],collapse=',')
  }
  print(c)
  d = distance(df_subspace[,], method = "tanimoto")
  rownames(d) <- c
  colnames(d) <- c
  
  d = as.dist(d)
  hr <- hclust(d, method = "complete", members=NULL)
  names(hr)
  par(mfrow = c(1, 2)); #plot(hr, hang = 0.1);
  print(d)
  
  plot(as.dendrogram(hr), edgePar=list(col=5, lwd=4), horiz=T) 
  #dev.off()
})

output$dendogram_top = renderPlot({
  df = models()
  if(is.null(df)) return(NULL)
  print('Displaying dendrogram based on dimension similarity of subspaces')
  ncols <- ncol(df$adata)
  nsubspace <- 2 ^ ncols - 1
  c=vector()
  df_subspace=data.frame(matrix(ncol=ncols, nrow=nsubspace))
  colnames(df_subspace) <- names(df$adata)
  for (i in 1:nsubspace) {
    df_subspace[i,] = as.binary(i, n = ncols)
    df_subspace[i,] = as.binary(i, n = ncols)
    t=names(df_subspace)
    
    x=as.numeric(df_subspace[i,])
    c[i]=paste(t[as.logical(x)],collapse=',')
  }
  print(c)
  d = distance(df_subspace[,], method = "tanimoto")
  rownames(d) <- c
  colnames(d) <- c
  
  d = as.dist(d)
  hr <- hclust(d, method = "complete", members=NULL)
  names(hr)
  par(mfrow = c(1, 2)); #plot(hr, hang = 0.1);
  print(d)
  
  plot(as.dendrogram(hr), edgePar=list(col=5, lwd=4), horiz=T) 
  #dev.off()
})


output$allplots <- renderUI ({
  df = models()
  if(is.null(df)) return(NULL)
  print('Displaying all Heidi images')
  #print(df$adata)
  newdata = data.frame(df$adata,df$label)
  pd = import('pandas')
  pd_adata = r_to_py(df$adata)
  pd_label = r_to_py(df$label)
  
  source_python('subspaceImage.py')
  #print (add(5,10,pd_adata))
  img_path = subspaceImageHelper(pd_adata, pd_label)
  nplot = length(img_path)
  print(img_path)
  output$legend1 <- renderUI ({
    includeHTML('./legend.html')
  })
  #dev.off()
  
  plot_output_list <- lapply(1:nplot, function(i) {
    plotname <- paste('aplot', i, sep='')
    plotOutput(plotname, height = 280, width = 250,inline=TRUE)#, display='inline-block')
  })
  
  for(i in 1:nplot) {
    local({
      my_i <- i
      plotname <- paste('aplot',my_i,sep='')
      
      output[[plotname]] <- renderImage({
        outfile <- tempfile(fileext='.png')
        png(outfile, width=200, height = 250)
        list(src=img_path[[my_i]],width=200, height = 250)
      }, deleteFile = FALSE)
      while (!is.null(dev.list()))  dev.off()
    })
  }
  
  print(plot_output_list)
  do.call(tagList, plot_output_list)
  
})

}
