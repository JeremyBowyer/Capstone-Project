# Prediction Algorithm -- Requires that 2,3,4-gram tables and discount rates
text_pred <- function(statement) {
  
  # Check to make sure required tables are loaded into environment
  if(!exists("quadgramAll")) {stop("Please load in quadgram DF")}
  if(!exists("trigramAll")) {stop("Please load in trigram DF")}
  if(!exists("bigramAll")) {stop("Please load in bigram DF")}
  
  if(!exists("quad_disc")) {stop("Please load in quadgram Discounts")}
  if(!exists("tri_disc")) {stop("Please load in trigram Discunts")}
  if(!exists("bi_disc")) {stop("Please load in bigram Discounts")}
  
  clean <- clean_input(statement)
  clean_length <- length(clean)
  
  ## create list of all potential terminating words ##
  words <- bigramAll[bigramAll$First == clean[clean_length], "Prediction"]
  words <- data.frame(Prediction = words,
                      Probability = NA,
                      stringsAsFactors = FALSE)
  words <- words[order(words$Prediction), ]
  
  ## Populate Candidate Probabilities
  if(clean_length >= 3) {
    ## Quadgram ##
    quad_candidates <- quad_candidates_func(clean)
    quad_leftover <- calc_leftover(quad_candidates)
    
    ## Trigram ##
    tri_candidates <- tri_candidates_func(clean, leftover = TRUE, leftover_prob = quad_leftover, left_over_words = quad_candidates$Prediction)
    tri_leftover <- calc_leftover(tri_candidates)
    
    ## Bigram ##
    bi_candidates <- bi_candidates_func(clean, leftover = TRUE, leftover_prob = quad_leftover * tri_leftover, left_over_words = c(quad_candidates$Prediction, tri_candidates$Prediction))
    bi_leftover <- calc_leftover(bi_candidates)
    
    ## Add probabilities to candidate list
    words[words$Prediction %in% quad_candidates$Prediction, "Probability"] <- quad_candidates$Probability
    words[words$Prediction %in% tri_candidates$Prediction, "Probability"] <- tri_candidates$Probability
    words[words$Prediction %in% bi_candidates$Prediction, "Probability"] <- bi_candidates$Probability
  } else if(clean_length == 2) {
    ## Trigram ##
    tri_candidates <- tri_candidates_func(clean)
    tri_leftover <- calc_leftover(tri_candidates)
    
    ## Bigram ##
    bi_candidates <- bi_candidates_func(clean, leftover = TRUE, leftover_prob = tri_leftover, left_over_words = tri_candidates$Prediction)
    bi_leftover <- calc_leftover(bi_candidates)
    
    ## Add probabilities to candidate list
    words[words$Prediction %in% tri_candidates$Prediction, "Probability"] <- tri_candidates$Probability
    words[words$Prediction %in% bi_candidates$Prediction, "Probability"] <- bi_candidates$Probability
  } else if(clean_length == 1) {
    ## Bigram ##
    bi_candidates <- bi_candidates_func(clean)
    
    ## Add probabilities to candidate list
    words[words$Prediction %in% bi_candidates$Prediction, "Probability"] <- bi_candidates$Probability
  }
  
  words <- words[order(words$Probability, decreasing = TRUE), ]
  return(words)
}

# Calculate leftover probability
calc_leftover <- function(df) {
  disc <- 1 - (sum(df$Adj.Freq, na.rm = TRUE) / sum(df$Freq, na.rm = TRUE))
  disc <- replace(disc, is.nan(disc), 1)
  return(disc)
}

## Rebieve terminating words from 3-gram DF, given a cleaned text input
bi_candidates_func <- function(clean, leftover = FALSE, leftover_prob, left_over_words) {
  if(leftover & !exists("leftover_prob")) {stop("Must supply leftover quantity from higher order n-gram")}
  if(leftover & !exists("left_over_words")) {stop("Must supply word list from higher order n-gram to be excluded")}
  
  clean_length <- length(clean)
  
  # Retrieve list
  bi_candidates <- bigramAll[bigramAll$First == clean[clean_length], ]
  
  # Remove words from higher order n-gram
  if(leftover) {
    bi_candidates <- bi_candidates[!bi_candidates$Prediction %in% left_over_words, ]
  }
  
  # Add discount rate
  bi_candidates <- merge(bi_candidates, bi_disc, by.x = "Freq", by.y = "frequency", all.x = TRUE)
  
  # Adjust frequencies down by discount
  bi_candidates$Adj.Freq <- bi_candidates$Freq * bi_candidates$Discount
  
  # Calculate Probability
  bi_candidates$Probability <- bi_candidates$Adj.Freq / sum(bi_candidates$Freq, na.rm = TRUE)
  
  # Adjust probability down by higher order leftover probability
  if(leftover) {
    bi_candidates$Probability <- bi_candidates$Probability * leftover_prob
  }
  
  # Sort alphabetically to facilitate merging with words DF
  bi_candidates <- bi_candidates[order(bi_candidates$Prediction), ]
  
  # Return Candidate DF
  return(bi_candidates)
}

## Retrieve terminating words from 3-gram DF, given a cleaned text input
tri_candidates_func <- function(clean, leftover = FALSE, leftover_prob, left_over_words) {
  if(leftover & !exists("leftover_prob")) {stop("Must supply leftover quantity from higher order n-gram")}
  if(leftover & !exists("left_over_words")) {stop("Must supply word list from higher order n-gram to be excluded")}
  
  clean_length <- length(clean)
  
  # Retrieve list
  tri_candidates <- trigramAll[trigramAll$First == clean[clean_length - 1] & 
                                 trigramAll$Second == clean[clean_length], ]
  
  # Remove words from higher order n-gram
  if(leftover) {
    tri_candidates <- tri_candidates[!tri_candidates$Prediction %in% left_over_words, ]
  }
  
  # Add discount rate
  tri_candidates <- merge(tri_candidates, tri_disc, by.x = "Freq", by.y = "frequency", all.x = TRUE)
  
  # Adjust frequencies down by discount
  tri_candidates$Adj.Freq <- tri_candidates$Freq * tri_candidates$Discount
  
  # Calculate Probability
  tri_candidates$Probability <- tri_candidates$Adj.Freq / sum(tri_candidates$Freq, na.rm = TRUE)
  
  # Adjust probability down by higher order leftover probability
  if(leftover) {
    tri_candidates$Probability <- tri_candidates$Probability * leftover_prob
  }
  
  # Sort alphabetically to facilitate merging with words DF
  tri_candidates <- tri_candidates[order(tri_candidates$Prediction), ]
  
  # Return Candidate DF
  return(tri_candidates)
}

## Retrieve terminating words from 4-gram DF, given a cleaned text input
quad_candidates_func <- function(clean) {
  clean_length <- length(clean)
  
  # Retrieve list
  quad_candidates <- quadgramAll[quadgramAll$First == clean[clean_length - 2] & 
                                   quadgramAll$Second == clean[clean_length - 1] &
                                   quadgramAll$Third == clean[clean_length], ]
  
  # Add discount rate
  quad_candidates <- merge(quad_candidates, quad_disc, by.x = "Freq", by.y = "frequency", all.x = TRUE)
  
  # Adjust frequencies down by discount
  quad_candidates$Adj.Freq <- quad_candidates$Freq * quad_candidates$Discount
  
  # Calculate Probability
  quad_candidates$Probability <- quad_candidates$Adj.Freq / sum(quad_candidates$Freq, na.rm = TRUE)
  
  # Sort alphabetically to facilitate merging with words DF
  quad_candidates <- quad_candidates[order(quad_candidates$Prediction), ]
  
  # Return Candidate DF
  return(quad_candidates)
}

# Good-Turing Discounts
GT_discount <- function(frequency) {
  # Find frequency of frequencies and store as data frame
  freqs <- as.data.frame(table(frequency), stringsAsFactors = FALSE)
  freqs$frequency <- as.numeric(freqs$frequency)
  freqs <- freqs[order(freqs$frequency, decreasing = FALSE), ]
  
  # Add next frequency and next frequency of frequencies to data frame
  freqs$Next_frequency <- c(freqs$frequency[-1],NA)
  freqs$Next_Freq <- c(freqs$Freq[-1],NA)
  
  # calculate discount rate for each frequency
  freqs$Discount <- (freqs$Next_frequency / freqs$frequency) * (freqs$Next_Freq / freqs$Freq)
  freqs$Discount[which.max(freqs$frequency)] <- 1
  
  # Remove unecessary columns
  freqs <- freqs[, c("frequency", "Discount")]
  
  # Override frequency > 10
  freqs[freqs$frequency > 10, "Discount"] <- 1
  
  # Return resulting DF
  return(freqs)
}


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
  cleaninput <- tm_map(cleaninput, removeWords, profanity)
  cleaninput <- tm_map(cleaninput, stripWhitespace)
  
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
