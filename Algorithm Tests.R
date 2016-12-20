library(DBI)
library(RMySQL)
library(RODBC)
library(tm)
library(stringi)
library(RWeka)
library(stringr)
library(quanteda)
library(rJava)

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

time1 <- Sys.time()
statement <- "why are they"

statement <- clean_input(statement)

query <- paste0("SELECT Prediction
                 FROM bowyeran_daily_betting.quadgram
                 WHERE First = '",statement[1],"' ",
                "AND Second = '",statement[2],"' ",
                "AND Third = '",statement[3],"'")

## Create Connection
con <- dbConnect(MySQL(),user= myUsername, password = myPassword, dbname = myDbname, host = myHost)

predRes <- dbSendQuery(con, query)
pred <- dbFetch(predRes, n = 1)
suppressWarnings(killDbConnections())

pred
time2 <- Sys.time()
time2 - time1


bigramAll$Prob <- NA
time1 <- Sys.time()
for(r in 15000:16000){
  bigramAll[r, "Prob"] <- bigramAll[r, "Freq"] / sum(bigramAll$Freq[bigramAll$First == bigramAll[r, "First"]], na.rm = TRUE)
}
time2 <- Sys.time()
time2 - time1


sums <- aggregate(bigramAll$Freq, by = list(bigramAll$First), sum)
bigramAll$Prob <- NA
time1 <- Sys.time()
for(r in 15000:16000){
  bigramAll[r, "Prob"] <- bigramAll[r, "Freq"] / sums$x[sums$Group.1 == bigramAll$First[r]]
}
time2 <- Sys.time()
time2 - time1

load("./Files/bigramAll.RD")
nrow(bigramAll)
object.size(bigramAll)

bigramAll <- bigramAll[bigramAll$Freq > 1, ]
nrow(bigramAll)
object.size(bigramAll)

bigramAll <- bigramAll[bigramAll$Freq > 4, ]
nrow(bigramAll)
object.size(bigramAll)

bigramAll <- bigramAll[bigramAll$Freq > 9, ]
nrow(bigramAll)
object.size(bigramAll)
