library(shiny)
library(tm)
library(stringi)
library(stringr)
library(quanteda)
library(wordcloud)
library(RColorBrewer)

# Load Functions
source("Functions.R", local = TRUE)

# Set Options
options(stringsAsFactors = FALSE)

# Load tables
load("bigram.RD")
load("trigram.RD")
load("quadgram.RD")
load("unigramTop20.RD")

# Load Discount Rates
load("bi_disc.RD")
load("tri_disc.RD")
load("quad_disc.RD")

# Load Profanity list, used to clean inputs
# from https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words
con <- file("profanity.txt")
profanity <- readLines(con)
close(con)


# Define server logic to run text prediction
shinyServer(function(input, output) {
  
  reactive_pred <- reactive({
    
    if(input$text != '') {
      # if the user typed some words, run text prediction and return result
      statement <- input$text
      predictions <- tryCatch(text_pred(statement), error = function(e) NULL)
      Table <- predictions[1:20, ]
      Prediction <- predictions[1, "Prediction"]
      
      return(list(Table = Table, Prediction = Prediction))
      
    }
  })
  
  # Create condition to be used in UI to determine if panel should be diplayed
  condition_check <- reactive({ length(reactive_pred()[["Prediction"]]) })
  output$condition <- renderText({ condition_check() })
  outputOptions(output, 'condition', suspendWhenHidden = FALSE)
  
  
  ## Output Prediction
  output$Prediction = renderPrint({ 
    
    if(input$text != '') {
      # If user has typed some words, return top word.
      output.statement <- reactive_pred()[["Prediction"]]
      if(length(output.statement) != 0) {
        # If a prediction exists, use it
        as.character(output.statement) 
      } else "No prediction. Keep typing!"
      
    }
  })
  
  ## Word Cloud
  # create color pallete
  pal <- brewer.pal(11, "Spectral")
  
  # output plot
  output$WordCloud = renderPlot({
    
    if(input$text != '') {
      # If user has typed some words, retrieve prediction table to be used in wordcloud
      # extract table
      prob_table <- reactive_pred()[["Table"]]
      
      # Create plot
      if(nrow(prob_table) != 0) {
        # If there are predictions, use them in wordcloud
        wordcloud(prob_table$Prediction, prob_table$Probability, colors = pal, fixed.asp = FALSE, rot.per = 0, random.order = FALSE, scale = c(8, 1))
      }
    }
  }, execOnResize = TRUE, width = 500, height = 500)
  
  ## Output Table
  output$Table <- renderTable({
    
    if(input$text != '') {
      #If user has typed some words, display table of predictions
      probs_table <- reactive_pred()[["Table"]][1:10, ]
      probs_table
    }
  }, striped = TRUE, bordered = TRUE)
  
})
