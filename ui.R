header <- dashboardHeader(title = "Projeto de Estatística")

sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("Dados", tabName = "movie_metrics", icon = icon("chart-line")),
        menuItem('Comparando Filmes', tabName = 'stat_comp', icon = icon('chart-bar'))
    )
)

body <- dashboardBody(
    tabItems(
        tabItem(tabName = 'movie_metrics',
                fluidRow(
                    box(title = 'Selecione suas opções', width=12, solidHeader = TRUE, status='warning',
                        selectInput('movie_stat', 'Métrica', movie_stat_list, multiple=FALSE),
                        uiOutput("time_date"),
                        actionButton('go', 'Pesquisar')
                    )
                ),
                fluidRow(
                    box(title = "Informações sobre os atributos", width = 12, solidHeader = TRUE,
                        DTOutput('info')
                    )
                ),
                fluidRow(
                    box(title = "Série de Preços", width = 12, solidHeader = TRUE,
                        plotOutput('sh')
                    )
                ),
        ),
        tabItem(tabName = 'stat_comp',
                fluidRow(
                    box(title = 'Selecione suas opções', width=12, solidHeader = TRUE, status='warning',
                        selectInput('movie_stat_comp', 'Métrica', movie_stat_list, multiple=TRUE),
                        uiOutput("time_date_comp"),
                        actionButton('go_comp', 'Pesquisar')
                    )
                ),            
        )
    )
)

ui <- dashboardPage(
    skin = 'blue',
    header, sidebar, body)
