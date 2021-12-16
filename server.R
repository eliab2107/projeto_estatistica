
# Define server logic required to draw a histogram
server <- function(input, output) {
    ################### INPUT ####################
    select_movie_stat <- eventReactive(input$go, {
        
        movie_stat <- input$movie_stat
        switch (movie_stat,
          "Orçamento" = movie_stat <- "Production.Budget",
          "Bilheteria Americana" = movie_stat <- "Domestic.Gross",
          "Bilheteria Mundial" = movie_stat <- "Worldwide.Gross"
        )

        twin <- input$true_date
        
        df_movie_stat <- master_df %>% 
            select(movie_stat)
        ## FALTA -> FILTRAR O DF POR DATA!!

        return(df_movie_stat)
    })
    
    output$time_date <- renderUI({
        
        movie_stat <- input$movie_stat
        switch (movie_stat,
          "Orçamento" = movie_stat <- "Production.Budget",
          "Bilheteria Americana" = movie_stat <- "Domestic.Gross",
          "Bilheteria Mundial" = movie_stat <- "Worldwide.Gross"
        )
        
        df <- master_df %>% 
            select(movie_stat)
        
        min_time <- min(df$Release.Date)
        max_time <- max(df$Release.Date)
        dateRangeInput( "true_date", "Período de análise",
            end = max_time,
            start = min_time,
            min  = min_time,
            max  = max_time,
            format = "dd/mm/yy",
            separator = " - ",
            language='pt-BR'
        )
    })
    
    output$time_date_comp <- renderUI({
        
        movie_stat <- input$movie_stat_comp
        
        df <- master_df %>% 
            filter(Index %in% movie_stat)
        
        maxmin_time <- df %>% 
            group_by(Index) %>% 
            summarise(MD = min(Release.Date)) %>% 
            .$MD %>% 
            max()
        
        minmax_time <- df %>% 
            group_by(Index) %>% 
            summarise(MD = max(Release.Date)) %>% 
            .$MD %>% 
            min()
        
        min_time <- maxmin_time
        max_time <- minmax_time
        
        dateRangeInput("true_date_comp", "Período de análise",
                       end = max_time,
                       start = min_time,
                       min    = min_time,
                       max    = max_time,
                       format = "dd/mm/yy",
                       separator = " - ",
                       language='pt-BR')
    })
    
    ################ OUTPUT #####################
    Info_DataTable <- eventReactive(input$go,{
        df <- select_movie_stat()
        
        mean <- df %>% select(Close) %>% colMeans()
        Media <- mean[[1]]
        
        Stock <- input$movie_stat
        
        df_tb <-  data.frame(Stock, Media)
        
        df_tb <- as.data.frame(t(df_tb))
        
        # tb  <- as_tibble(cbind(nms = names(df_tb), t(df_tb)))
        # tb <- tb %>% 
        #     rename('Informações' = nms,
        #            'Valores' = V2)
        # 
        return(df_tb)
    })
    
    output$info <- renderDT({
        Info_DataTable() %>%
            as.data.frame() %>% 
            DT::datatable(options=list(
                language=list(
                    url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Portuguese-Brasil.json'
                )
            ))
    })
    
    output$sh <- renderPlot({
        # All the inputs
        df <- select_movie_stat()
        
        aux <- df$Close %>% na.omit() %>% as.numeric()
        aux1 <- min(aux)
        aux2 <- max(aux)
        
        df$Release.Date <- ymd(df$Release.Date)
        a <- df %>% 
            ggplot(aes(Release.Date, Close, group=1)) +
            geom_path() +
            ylab('Preço da Ação em $') +
            coord_cartesian(ylim = c(aux1, aux2)) +
            theme_bw() +
            scale_x_date(date_labels = "%Y-%m-%d")
        
        a
    })
}
