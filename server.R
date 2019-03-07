function(input,output) {
  
  set.seed(1000)

    observe({
    if(is.null(input$vars) || input$vars == ''){
      shinyjs::disable("action")
    }
    else {
      shinyjs::enable("action")
    }
  })
  
  # this piece of code hides and shows parallel coordinate and other plots based on variable selection
  observe({
    if (is.null(input$vars) || input$vars == "") {
      shinyjs::hide("parcoords")
      shinyjs::hide("allplots")
    }
  })
  
  observeEvent(input$action, {
    shinyjs::hide("parcoords2")
    shinyjs::show("parcoords")
    shinyjs::show("allplots")
  })
  
  # read in the dataset, remove any rows with missing data
  info <- reactive({
    infile <- input$file1
    if(is.null(infile)) {
      return(NULL)
    }
    t=read.table(infile$datapath, header = input$header, sep = input$sep)
    t=t[complete.cases(t),]
    return(t)
  })
  
  #show the variable names in the dataset for use
  output$vars <- renderUI({
    df <- info()
    if(is.null(df)) return (NULL)
    items=names(df)
    names(items)=items
    selectInput("vars","Select Variables",items,multiple = T, selected = NULL)
  })
  
  #select the variable with is cluster label
  output$label <- renderUI({
    df <- info()
    if(is.null(df)) return (NULL)
    items = names(df)
    names(items)=items
    selectInput("label","Select class Label", items, multiple=F)
  })
  
  #show the parallelcoordinateplot
  output$parcoords2 = renderParcoords({
    data=info()
    print('parcoodr2')
    if(is.null(data)) return(NULL)
    parcoords(data,rownames=F,brushMode="1d")
  })
  
  # main part of app
  models = eventReactive(input$action, {
    adata=info()
    adatause = adata[input$vars]
    adatalabel=adata[input$label]
    print(adata)
    #cnum = length(unique(adatalabel[1,]))
    #colors=c('#3366cc',"#ff9900", "#109618", "#dc3912", "#990099")
    #print(cnum)
    #print(adatalabel)
    
    int_subspace <- CLIQUE(adatause,xi=10,tau=0.06)
    print(int_subspace)
    #coloruse=colors[1:cnum]
    mat <- matrix(,nrow=nrow(adatause),ncol=nrow(adatause))
    t <- get.knn(adatause, k=5)
    for( i in 1:nrow(adatause)) {
      for (j in 1:nrow(adatause)) {
        if(j %in% t$nn.index[i,]) {
          mat[i,j]=0
        }
        else mat[i,j]=1
      }
    }
    rotate <- function(x) t(apply(x, 2, rev))
    #image(rotate(mat))
    
    newdat=data.frame(adatause,adatalabel)
    #allval=list(a=newdat,b=image(rotate(mat)),c=mat)
    allval=list(a=newdat,b=rotate(mat))
    allval
  })
  
  #parallel coordinate for selected variables
  output$parcoords = renderParcoords({
    allval=models()
    datause=allval$a
    parcoords(datause,rownames=F, brushMode="1d",color = list(colorBy="cluster",colorScale=htmlwidgets::JS('d3.scale.category10()')))
  })
  
  
  output$plot1 = renderImage({

    allval=models()
    print('allval')
    jpeg(file='temp2.jpeg', width=400, height=400)
    image(allval$b)
    dev.off()
    #hist(rnorm(allval$b))
    #dev.off()
    list(src = 'temp2.jpeg', alt = 'This is alternate text')
  }, deleteFile = TRUE)
  
  "
  # Insert the right number of plot output objects into the web page
  output$allplots <- renderUI({
    nplot=10
    plot_output_list <- lapply(1:nplot, function(i) {
      plotname <- paste('aplot', i, sep='')
      plotOutput(plotname, height = 280, width = 250)
    })
    
    for(i in 1:10) {
      local({
        my_i <- i
        plotname <- paste('aplot',my_i,sep='')
        
        output[[plotname]] <- renderImage({
          #jpeg(file='temp2.jpeg',width=400,height=400)
          #image(allval$b)
          #dev.off()
          list(src='temp.jpeg')
        }, deleteFile = FALSE)
      })
    }
    
    do.call(tagList, plot_output_list)
    
    
    
  })
  "
  
  
  

  
  
  
}