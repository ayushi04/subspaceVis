library(shiny)
library(shinySignals)
library(dplyr)
library(shinydashboard)
library(bubbles)
library(stargazer)
library(Rtsne)
library(plotly)
library(survival)
library(survminer)
library(GGally)
library(MASS)
library(parcoords)
library(cluster)
library(shinyjs)
library(pairsD3)
library('FNN')
#library(subspace)
library('reticulate')
library('imager')


dashboardPage(
  dashboardHeader(title="SubspaceAnalysisHeidi"),
  dashboardSidebar(
    fileInput('file1','choose file to upload',
    accept= c(
      'text/csv',
      'text/comma-seperated-values',
      'text/tab-seperated-values',
      'text/plain',
      '.csv',
      '.tsv'
    )
  ), #fileInout
  tags$hr(),
  checkboxInput('header',"Header", TRUE),
  radioButtons('sep','Seperator',
               c(Comma=',',Semicolon=';',Tab='\t'),
               ','), #radioButtons
  uiOutput("vars"),
  uiOutput("label"),
  tags$hr(),
  actionButton("action","Run"),
  
  sidebarMenu(
    menuItem(("Dashboard"),tabName = "dashboard"),
    menuItem(("Explore"),tabName="explore")
    )
  ),
  
  dashboardBody(
    useShinyjs(),
    tabItems(
      tabItem("dashboard",
        fluidRow(
          parcoordsOutput("parcoords2",width="100%", height=400),
          parcoordsOutput("parcoords",width="100%", height=400)
        )
        ,
        fluidRow(
          box(
           width = 5, status = "info", solidHeader = TRUE,
            title = "Heidi visualization",
            plotOutput("plot1")#,
            #uiOutput("plots")
            #plotlyOutput("packagePlot3", width = "100%", height = 400)
          ),
          box(
            width=2, status="info", solidHeader = TRUE,
            title="color legend",
            htmlOutput("legend")
          ),
          box(
            width=5, status="info", solidHeader = TRUE,
            title="dendogram",
            plotlyOutput("dendogram"),
            collapsible = TRUE,
            div(style = 'overflow-y: scroll')
          ),
          box(
            width = 12, status = "info", solidHeader = TRUE,
            title = "Heidi visualization",
            uiOutput("allplots"),
            div(style = 'overflow-x: scroll')
            #plotlyOutput("packagePlot3", width = "100%", height = 400)
          )
        )
      )#tabItem
    )#tabItems
  )
)