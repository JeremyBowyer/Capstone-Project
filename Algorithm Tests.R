library(DBI)
library(RMySQL)
library(RODBC)

# Set Working Directory and source functions script
setwd("F:/Documents/Data work/Coursera Capstone Project/Week 1")
source("./Scripts/Functions.R")


#### UPLOAD TO SQL ####

## Store Credentials
myHost <- "69.195.124.128";
myUsername = "bowyeran_main";
myDbname = "bowyeran_daily_betting";
myPort = "3306";
myPassword = "563Jb14123";



statement <- "why are you"


statement <- clean_input(statement)

query <- paste0("SELECT Prediction
                 FROM bowyeran_daily_betting.quadgram
                 WHERE First = '",statement[1],"' ",
                "AND Second = '",statement[2],"' ",
                "AND Third = '",statement[3],"'")

## Create Connection
con <- dbConnect(MySQL(),user= myUsername, password = myPassword, dbname = "bowyeran_daily_betting", host = myHost)

predRes <- dbSendQuery(con, query)
pred <- dbFetch(predRes, n = 1)
suppressWarnings(killDbConnections())

pred

