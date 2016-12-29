library(tm)
library(stringi)
library(RWeka)
library(stringr)
library(quanteda)
library(rJava)

# This script will loop through randomly
# sampled 1% chunks of the given corpora,
# clean each chunk, create n-gram dataframes,
# and save them as R objects.
# Then it will combine those dataframes
# as one large n-gram tawble, to be used in
# the text prediction algorithm. The reason
# We loop through small chunks is to get
# around R's memory limitation.

# Set Working Directory and source functions script
setwd("F:/Documents/Data work/Coursera Capstone Project/Week 1")
source("./Scripts/Functions.R")

# Set java memory option
options(java.parameters = "- Xmx16345m")

# Set desired TOTAL sample to use
total_sample <- 30

## Create start indices and sample sizes for each corpus to be used in each iteration
set.seed(7327)
prop <- 0.01
blog_index <- 1:length(blogs)
twitter_index <- 1:length(twitter)
news_index <- 1:length(news)

blog_sample_size <- round(0.01 * length(blogs))
twitter_sample_size <- round(0.01 * length(twitter))
news_sample_size <- round(0.01 * length(news))

# Loop through by 1% increments and create/clean corpus chunks

for(i in 1:total_sample) {
  time1 <- Sys.time()
  # Create Samples
  #blogs
  blog_current_sample <- sample(blog_index, blog_sample_size)
  blogs_sample <- blogs[blog_current_sample]
  blog_index <- blog_index[!blog_index %in% blog_current_sample]
  #twitter
  twitter_current_sample <- sample(twitter_index, twitter_sample_size)
  twitter_sample <- twitter[twitter_current_sample]
  twitter_index <- twitter_index[!twitter_index %in% twitter_current_sample]
  #news
  news_current_sample <- sample(news_index, news_sample_size)
  news_sample <- news[news_current_sample]
  news_index <- news_index[!news_index %in% news_current_sample]
  # all
  allSample <- c(blogs_sample, twitter_sample, news_sample)
  
  # fix encoding
  allSample <- iconv(allSample, from="UTF-8", to="ASCII", sub="")
  # collapse into single document
  allSample <- paste(allSample, collapse = " ")
  
  corp <- Corpus(VectorSource(allSample)) # create corpus for TM processing
  # remove unused text objects
  rm(allSample, blogs_sample, twitter_sample, news_sample)
  
  cleanCorp <- tm_map(corp, content_transformer(tolower), lazy = TRUE)
  rm(corp) # remove uncleaned corp to save space
  cleanCorp <- tm_map(cleanCorp, content_transformer(insertEOS))
  cleanCorp <- tm_map(cleanCorp, content_transformer(removePunctuation))
  cleanCorp <- tm_map(cleanCorp, content_transformer(removeNumbers))
  #cleanCorp <- tm_map(cleanCorp, removeWords, stopwords("english")) # was causing the model to be too specific
  cleanCorp <- tm_map(cleanCorp, content_transformer(removeURL))
  cleanCorp <- tm_map(cleanCorp, stripWhitespace)
  cleanCorp <- tm_map(cleanCorp, removeWords, profanity)
  
  if(i < 6) {
    # Unigram
    jgc()
    unigramDF <- ngram_freq_df(cleanCorp, 1)
    save(unigramDF, file = paste0("./Files/unigrams/unigramDF",i,".RD"))
    rm(unigramDF)
  }

  # Bigram
  jgc()
  bigramDF <- ngram_freq_df(cleanCorp, 2)
  save(bigramDF, file = paste0("./Files/bigrams/bigramDF",i,".RD"))
  rm(bigramDF)
  
  # Trigram
  jgc()
  trigramDF <- ngram_freq_df(cleanCorp, 3)
  save(trigramDF, file = paste0("./Files/trigrams/trigramDF",i,".RD"))
  rm(trigramDF)
  
  # Quadgram
  jgc()
  quadgramDF <- ngram_freq_df(cleanCorp, 4)
  save(quadgramDF, file = paste0("./Files/quadgrams/quadgramDF",i,".RD"))
  rm(quadgramDF)
  
  time2 <- Sys.time()
  print(time2 - time1)
}


# Combine n-gram dataframes from files and discount frequencies

# unigrams
for(i in 1:5) {
  time1 <- Sys.time()
  if(i == 1) {
    load("./Files/unigrams/unigramDF1.RD")
    unigramAll <- unigramDF
  } else if(i > 1) {
    filepath <- paste0("./Files/unigrams/unigramDF",i,".RD")
    load(filepath)
    unigramAll <- rbind(unigramAll, unigramDF)
    unigramAll <- aggregate(unigramAll$Freq, by = list(Prediction = unigramAll$Prediction), sum)
    names(unigramAll) <- gsub("x", "Freq", names(unigramAll))
    unigramAll <- unigramAll[order(unigramAll$Freq, decreasing = TRUE), ]
    unigramAll <- unigramAll[unigramAll$Prediction != "eos", ]
    rm(unigramDF)
  }
  save(unigramAll, file = "./Files/unigramAll.RD")
  print(paste0("unigram ",i," took"))
  time2 <- Sys.time()
  print(time2 - time1)
  print(format(object.size(unigramAll), units = "MB"))
}

# Only include n-grams with multiple occurences
unigramAll <- unigramAll[unigramAll$Freq > 1, ]
# Calculate Good-Turing Discount Rates for each frequency
uni_disc <- GT_discount(unigramAll$Freq)

# Add discount rate
unigramAll <- merge(unigramAll, uni_disc, by.x = "Freq", by.y = "frequency", all.x = TRUE)

# Adjust frequencies down by discount
unigramAll$Adj.Freq <- unigramAll$Freq * unigramAll$Discount

# Calculate Probability
unigramAll$Probability <- unigramAll$Adj.Freq / sum(unigramAll$Freq, na.rm = TRUE)

# Only keep top 20
unigramAll <- unigramAll[order(unigramAll$Freq, decreasing = TRUE), ]
unigramTop20 <- unigramAll[1:20, c("Prediction", "Probability")]

# save object
save(unigramTop20, file = "./Files/unigramTop20.RD")


# clean up environment
rm(unigramAll)
rm(uni_disc)

# bigrams
for(i in 1:total_sample) {
  time1 <- Sys.time()
  if(i == 1) {
    load("./Files/bigrams/bigramDF1.RD")
    bigramAll <- bigramDF
  } else if(i > 1) {
    filepath <- paste0("./Files/bigrams/bigramDF",i,".RD")
    load(filepath)
    bigramAll <- rbind(bigramAll, bigramDF)
    bigramAll <- aggregate(bigramAll$Freq, by = list(First = bigramAll$First,
                                                     Prediction = bigramAll$Prediction), sum)
    names(bigramAll) <- gsub("x", "Freq", names(bigramAll))
    bigramAll <- bigramAll[order(bigramAll$Freq, decreasing = TRUE), ]
    bigramAll <- bigramAll[bigramAll$First != "eos" & bigramAll$Prediction != "eos", ]
    rm(bigramDF)
  }
  save(bigramAll, file = "./Files/bigramAll.RD")
  print(paste0("bigram ",i," took"))
  time2 <- Sys.time()
  print(time2 - time1)
  print(format(object.size(bigramAll), units = "MB"))
}

# Only include n-grams with multiple occurences
bigramAll <- bigramAll[bigramAll$Freq > 1, ]
# Calculate Good-Turing Discount Rates for each frequency
bi_disc <- GT_discount(bigramAll$Freq)

# save object
save(bigramAll, file = "./Files/bigram.RD")
# save object
save(bi_disc, file = "./Files/bi_disc.RD")

# clean up environment
rm(bigramAll)
rm(bi_disc)

# trigrams
for(i in 1:total_sample) {
  time1 <- Sys.time()
  if(i == 1) {
    load("./Files/trigrams/trigramDF1.RD")
    trigramAll <- trigramDF
  } else if(i > 1) {
    filepath <- paste0("./Files/trigrams/trigramDF",i,".RD")
    load(filepath)
    trigramAll <- rbind(trigramAll, trigramDF)
    trigramAll <- aggregate(trigramAll$Freq, by = list(First = trigramAll$First,
                                                       Second = trigramAll$Second,
                                                       Prediction = trigramAll$Prediction), sum)
    names(trigramAll) <- gsub("x", "Freq", names(trigramAll))
    trigramAll <- trigramAll[order(trigramAll$Freq, decreasing = TRUE), ]
    trigramAll <- trigramAll[trigramAll$First != "eos" & trigramAll$Second != "eos" & trigramAll$Prediction != "eos", ]
    rm(trigramDF)
  }
  save(trigramAll, file = "./Files/trigramAll.RD")
  print(paste0("trigram ",i," took"))
  time2 <- Sys.time()
  print(time2 - time1)
  print(format(object.size(trigramAll), units = "MB"))
}
# Only include n-grams with multiple occurences
trigramAll <- trigramAll[trigramAll$Freq > 1, ]
# Calculate Good-Turing Discount Rates for each frequency
tri_disc <- GT_discount(trigramAll$Freq)

# save object
save(trigramAll, file = "./Files/trigram.RD")
# save object
save(tri_disc, file = "./Files/tri_disc.RD")

# clean up environment
rm(trigramAll)
rm(tri_disc)

# quadgrams
for(i in 1:total_sample) {
  time1 <- Sys.time()
  if(i == 1) {
    load("./Files/quadgrams/quadgramDF1.RD")
    quadgramAll <- quadgramDF
  } else if(i > 1) {
    filepath <- paste0("./Files/quadgrams/quadgramDF",i,".RD")
    load(filepath)
    quadgramAll <- rbind(quadgramAll, quadgramDF)
    quadgramAll <- aggregate(quadgramAll$Freq, by = list(First = quadgramAll$First,
                                                         Second = quadgramAll$Second,
                                                         Third = quadgramAll$Third,
                                                         Prediction = quadgramAll$Prediction), sum)
    names(quadgramAll) <- gsub("x", "Freq", names(quadgramAll))
    quadgramAll <- quadgramAll[order(quadgramAll$Freq, decreasing = TRUE), ]
    quadgramAll <- quadgramAll[quadgramAll$First != "eos" & quadgramAll$Second != "eos" & quadgramAll$Third != "eos" & quadgramAll$Prediction != "eos", ]
    rm(quadgramDF)
  }
  save(quadgramAll, file = "./Files/quadgramAll.RD")
  print(paste0("quadgram ",i," took"))
  time2 <- Sys.time()
  print(time2 - time1)
  print(format(object.size(quadgramAll), units = "MB"))
}
# Only include n-grams with multiple occurences
quadgramAll <- quadgramAll[quadgramAll$Freq > 1, ]
# Calculate Good-Turing Discount Rates for each frequency
quad_disc <- GT_discount(quadgramAll$Freq)

# save object
save(quadgramAll, file = "./Files/quadgram.RD")
# save object
save(quad_disc, file = "./Files/quad_disc.RD")

# clean up environment
rm(quadgramAll)
rm(quad_disc)