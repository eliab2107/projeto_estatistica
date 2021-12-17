server <- function(input,output) {
    select_movie_stat <- eventReactive(input$go,{
        
        movie_stat <- input$movie_stat
        switch(movie_stat,
          "Orçamento"=movie_stat <- "Production.Budget",
          "Bilheteria Americana"=movie_stat <- "Domestic.Gross",
          "Bilheteria Mundial"=movie_stat <- "Worldwide.Gross"
        )

        twin <- input$true_date
        
        df_movie_stat <- master_df %>% 
            select(Release.Date,movie_stat)

        return(df_movie_stat)
    })
    
    output$time_date <- renderUI({
        
        movie_stat <- input$movie_stat
        switch(movie_stat,
          "Orçamento"=movie_stat <- "Production.Budget",
          "Bilheteria Americana"=movie_stat <- "Domestic.Gross",
          "Bilheteria Mundial"=movie_stat <- "Worldwide.Gross"
        )
        
        df <- master_df %>% 
            select(movie_stat)
        
        min_time <- min(as.Date(unlist(df$Release.Date)))
        max_time <- max(as.Date(unlist(df$Release.Date)))
        dateRangeInput( "true_date","Período de análise",
            end=max_time,
            start=min_time,
            min=min_time,
            max=max_time,
            format="yyyy/mm/dd",
            separator="/",
            language='pt-BR'
        )
    })
    
    output$time_date_comp <- renderUI({
        
        movie_stat <- input$movie_stat_comp
        
        df <- master_df %>% 
            filter(Index %in% movie_stat)
        
        maxmin_time <- df %>% 
            group_by(Index) %>% 
            summarise(MD=min(Release.Date)) %>% 
            .$MD %>% 
            max()
        
        minmax_time <- df %>% 
            group_by(Index) %>% 
            summarise(MD=max(Release.Date)) %>% 
            .$MD %>% 
            min()
        
        min_time <- maxmin_time
        max_time <- minmax_time
        
        dateRangeInput("true_date_comp","Período de análise",
                       end=max_time,
                       start=min_time,
                       min=min_time,
                       max=max_time,
                       format="yyyy/mm/dd",
                       separator="/",
                       language='pt-BR'
        )
    })
    
    ################ OUTPUT #####################
    Info_DataTable <- eventReactive(input$go,{
        df <- select_movie_stat()
        
        mean <- select(df,2) %>% colMeans()
        Media <- mean[1]

        mod <- unique(as.numeric(unlist(select(df,2))))
        ux <- unique(mod)
        Moda <- mod[which.max(tabulate(match(mod, ux)))]
        
        Mediana <- as.numeric(unlist(select(df,2))) %>% median()

        Desvio <- sd(as.double(unlist(select(df,2))))
        
        Atributo <- input$movie_stat
        
        df_tb <- data.frame(Atributo,Media,Moda,Mediana,Desvio)
        
        df_tb <- as.data.frame(t(df_tb))
        
        return(df_tb)
    })
    
    output$info <- renderDT({
        Info_DataTable() %>%
            as.data.frame() %>% 
            DT::datatable(options=list(
                language=list(
                    url='//cdn.datatables.net/plug-ins/1.10.11/i18n/Portuguese-Brasil.json'
                )
            ))
    })
    
    output$sh <- renderPlot({
        #Puxa uma tabela contendo só data e o atributo escolhido
        df <- select_movie_stat()
        
        #a casa 1 (em r 2) do array guarda o atributo a ser tratado
        aux <- unlist(df[1])
        aux <- as.POSIXct(as.numeric(as.character(strptime(aux, format='%m/%d/%Y'))),origin="GMT")
        aux1 <- min(aux)
        aux2 <- max(aux)
        
        df$Release.Date <- ymd(df$Release.Date)
        a <- df %>% 
            ggplot(aes(Release.Date,df[2],group=1))+
            geom_path()+
            ylab('Preço da Ação em $')+
            coord_cartesian(ylim=c(aux1,aux2))+
            theme_bw()+
            scale_x_date(date_labels="%m/%d/%Y")
        a
    })
}