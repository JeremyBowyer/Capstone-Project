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

# Write DFs to SQL
# Bigram
## Create Connection
con <- dbConnect(MySQL(),user= myUsername, password = myPassword, dbname = myDbname, host = myHost)
load("./Files/bigramAll.RD")
dbWriteTable(con, "bigram", bigramAll)
rm(bigramAll)

# Trigram
## Create Connection
con <- dbConnect(MySQL(),user= myUsername, password = myPassword, dbname = "bowyeran_daily_betting", host = myHost)
load("./Files/trigramAll.RD")
dbWriteTable(con, "trigram", trigramAll)
rm(trigramAll)

# Quadgram
## Create Connection
con <- dbConnect(MySQL(),user= myUsername, password = myPassword, dbname = "bowyeran_daily_betting", host = myHost)
load("./Files/quadgramAll.RD")
dbWriteTable(con, "quadgram", quadgramAll)
rm(quadgramAll)

dbListTables(con) # to see what all tables the database has
