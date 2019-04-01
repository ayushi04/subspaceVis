library(parcoords)

dashboardPage(
  dashboardHeader(title="Subspace Visualization"),
  dashboardSidebar(
    #file-input
    fileInput('file1','choose file to upload',
              accept= c(
                'text/csv',
                'text/comma-seperated-values',
                'text/tab-seperated-values',
                'text/plain',
                '.csv',
                '.tsv'
              )), #file-input-end
    
    tags$hr(),
    checkboxInput('header','Header',TRUE),
    radioButtons('sep','Sepeerator',
                 c(Comma=',',Semicolon=';',Tab='\t')),
    uiOutput('vars'),
    uiOutput('label'),
    uiOutput('id'),
    
    tags$hr(),
    
    actionButton('action','Run'),
    
    #TODO Later
    sidebarMenu(
      menuItem(('Dashboard'),tabName='dashboard'),
      menuItem(('Explore'),tabName='explore')
    )
    
  ),#dashboardSidebar-end
  
  dashboardBody(
    useShinyjs(),
    tabItems(
      tabItem("dashboard",
              fluidRow(
                parcoordsOutput("parcoords2",width="100%", height=400),
                parcoordsOutput('parcoords',width="100%", height = 400)
              ),
              fluidRow(
                box(
                  width = 6, status ="info", solidHeader = TRUE,
                  title = "Dendogram_subspace",
                  plotOutput("dendogram_subspace", width = "100%", height = 400)
                ),
                box(
                  width = 6, status ="info", solidHeader = TRUE,
                  title = "Dendogram_topological",
                  plotOutput("dendogram_top", width = "100%", height = 400)
                ),
                box(
                  width = 10, status = "info", solidHeader = TRUE,
                  title = "Heidi visualization",
                  uiOutput("allplots"),
                  div(style = 'overflow-x: scroll')
                  ),
                box(
                  width=2, status="info", solidHeader = TRUE,
                  title="color legend",
                  htmlOutput("legend1")
                )
              )
              )#tabitem1
    )#tabitem's'
  )
)