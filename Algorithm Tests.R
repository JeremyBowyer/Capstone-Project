library(DBI)
library(RMySQL)
library(RODBC)

#### UPLOAD TO SQL ####

## Store Credentials
myHost <- "69.195.124.128";
myUsername = "bowyeran_main";
myDbname = "bowyeran_daily_betting";
myPort = "3306";
myPassword = "563Jb14123";

## Create Connection
con <- dbConnect(MySQL(),user= myUsername, password = myPassword, dbname = "bowyeran_daily_betting", host = myHost)