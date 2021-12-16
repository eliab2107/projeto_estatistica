library(quantmod)
library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(DT)
library(tidyverse)
library(lubridate)

master_df <- read.csv('movies_data.csv')
movie_stat_list <- c('Orçamento', 'Bilheteria Americana', 'Bilheteria Mundial')

master_df$X <- NULL

master_df <- master_df %>% drop_na()
master_df$Release.Date <- strptime(master_df$Release.Date, format='%m/%d/%Y')