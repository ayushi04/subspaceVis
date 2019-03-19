


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
    #print(adata)
    #df <- adatause
    #df['classLabel'] <-adata[input$label]
    #cnum = length(unique(adatalabel[1,]))
    #colors=c('#3366cc',"#ff9900", "#109618", "#dc3912", "#990099")
    #print(cnum)
    #print(adatalabel)
    
    #int_subspace <- CLIQUE(adatause,xi=10,tau=0.06)
    #print(int_subspace)
    #coloruse=colors[1:cnum]
    
    newdat=data.frame(adatause,adatalabel)
    
    
    source_python("heidiVisualization.py")
    img_path = test_func(r_to_py(newdat))
    print(img_path)
    #print('jjjj',img_path)
    #allval=list(a=newdat,b=image(rotate(mat)),c=mat)
    #im<-load.image(img_path)
    allval=list(a=newdat,b=img_path)
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
    #print('allval',allval$b)
    #jpeg(file='temp2.jpeg', width=400, height=400)
    #image(allval$b)
    #dev.off()
    #hist(rnorm(allval$b))
    #dev.off()
    list(src = allval$b, alt = 'This is alternate text', width=400, height=400)
  }, deleteFile = TRUE)
  
  
  # Insert the right number of plot output objects into the web page
  output$allplots <- renderUI({
    adata=info()
    adatause = adata[input$vars]
    adatalabel=adata[input$label]
    newdat=data.frame(adatause,adatalabel)
    source_python("subspaceImage.py")
    img_path = subspaceImageHelper(r_to_py(adatause),r_to_py(adatalabel))
    
    nplot=length(img_path)
    print(img_path)
    output$legend <- renderUI ({
      includeHTML('./legend.html')
    })
    
    plot_output_list <- lapply(1:nplot, function(i) {
      plotname <- paste('aplot', i, sep='')
      plotOutput(plotname, height = 280, width = 250,inline=TRUE)#, display="inline-block")
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
      })
    }
    do.call(tagList, plot_output_list)
    
    
  })
  
  
  output$dendogram <- renderPlotly({
    adata=info()
    hc <- hclust(dist(USArrests),"ave")
    dend1 <- as.dendrogram(hc)
    plot_dendro(dend1, height = 450)
  })
  
  
  
  
  
  
  
  
  
  

  
  
  
}