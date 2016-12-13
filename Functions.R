# kill DB connections
killDbConnections <- function () {
  
  all_cons <- dbListConnections(MySQL())
  
  for(con in all_cons)
    +  dbDisconnect(con)
  
}

# clean text
clean_input <- function(text) {
  # check for necessary conditions
  if(class(text) != "character") {stop("Must supply character vector")}
  if(length(text) != 1) {stop("Character vector must be length 1")}
  
  input <- Corpus(VectorSource(text)) # create corpus for TM processing
  
  cleaninput <- tm_map(input, content_transformer(tolower), lazy = TRUE)
  rm(input) # remove uncleaned corp to save space
  cleaninput <- tm_map(cleaninput, content_transformer(insertEOS))
  cleaninput <- tm_map(cleaninput, content_transformer(removePunctuation))
  cleaninput <- tm_map(cleaninput, content_transformer(removeNumbers))
  #cleaninput <- tm_map(cleaninput, removeWords, stopwords("english")) # was causing the model to be too specific
  cleaninput <- tm_map(cleaninput, content_transformer(removeURL))
  cleaninput <- tm_map(cleaninput, stripWhitespace)
  cleaninput <- tm_map(cleaninput, removeWords, profanity)
  
  split_input <- unlist(strsplit(cleaninput[[1]]$content, " "))
  
  return(split_input)
}

# java garbage collection
jgc <- function()
{
  gc()
  .jcall("java/lang/System", method = "gc")
}   

# Corpus cleaning
removeURL <- function(x) gsub("http[[:alnum:]]*", "", x) 
removeAbnormal <- function(x) gsub("â", "", gsub("€", "", gsub("™", "", x))) 
insertEOS <- function(x) gsub("\\.+", " EOS ", gsub("\\?+", " EOS ", gsub("\\!+", " EOS ", x))) 


# Generate n-grams function
ngram_freq_df <- function(corpus, ng){
  
  options(mc.cores=1) # http://stackoverflow.com/questions/17703553/bigrams-instead-of-single-words-in-termdocument-matrix-using-r-and-rweka/20251039#20251039
  ngramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = ng, max = ng)) # create n-grams
  DTM <- DocumentTermMatrix(corpus, control = list(tokenize = ngramTokenizer)) # create tdm from n-grams
  DTM_M <- as.matrix(DTM)
  ngramTerms <- colnames(DTM_M) # store terms
  ngramWords <- str_split_fixed(ngramTerms, " ", ng) # split terms into words
  ngramFreq <- colSums(DTM_M) # extract frequencies from DTM matrix
  
  if(ng == 2){
    ngramDF <- data.frame(First = ngramWords[, 1],
                          Prediction = ngramWords[, 2],
                          Freq = ngramFreq,
                          stringsAsFactors = FALSE)
  }
  
  if(ng == 3){
    ngramDF <- data.frame(First = ngramWords[, 1],
                          Second = ngramWords[, 2],
                          Prediction = ngramWords[, 3],
                          Freq = ngramFreq,
                          stringsAsFactors = FALSE)
  }
  
  if(ng == 4){
    ngramDF <- data.frame(First = ngramWords[, 1],
                          Second = ngramWords[, 2],
                          Third = ngramWords[, 3],
                          Prediction = ngramWords[, 4],
                          Freq = ngramFreq,
                          stringsAsFactors = FALSE)
  }
  
  ngramDF <- ngramDF[order(ngramDF$Freq, decreasing = TRUE), ]
  row.names(ngramDF) <- 1:nrow(ngramDF)
  
  ngramDF
}

# proportional text sampling
prop_sample <- function(text, proportion) {
  taking <- sample(1:length(text), length(text)*proportion)
  Sampletext <- text[taking]
  Sampletext
}
