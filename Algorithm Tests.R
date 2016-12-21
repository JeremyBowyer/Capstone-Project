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

# clean environment
rm(list = ls())

# Load tables
load("./Files/bigram.RD")
load("./Files/trigram.RD")
load("./Files/quadgram.RD")

load("./Files/bi_disc.RD")
load("./Files/tri_disc.RD")
load("./Files/quad_disc.RD")

# Profanity
# from https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words
con <- file("./Files/profanity.txt")
profanity <- readLines(con)
close(con)

#### Test Algorithm ####

statement <- "why are they"


# Add discount rates to bigram DF
bigramAll <- merge(bigramAll, bi_disc, by.x = "Freq", by.y = "frequency", all.x = TRUE)

# Create adjusted frequency
bigramAll$Adj.Freq <- bigramAll$Freq * bigramAll$Discount

# Calculate adjusted frequency sums for each preceding n-gram
bi_sums <- aggregate(bigramAll$Adj.Freq, by = list(bigramAll$First), sum)

# Calculate probabilities. Prediction frequency / sum of preceding n-gram
bigramAll <- merge(bigramAll, bi_sums, by.x = "First", by.y = "Group.1", all.x = TRUE)
bigramAll$GT_Prob <- bigramAll$Adj.Freq / bigramAll$x

# Only include relevant fields to reduce memory usage
bigramAll <- bigramAll[, c("First", "Prediction", "GT_Prob")]