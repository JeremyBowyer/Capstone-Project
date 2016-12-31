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

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  reactive_pred <- reactive({
    
    if(input$text != '') {
      
      statement <- input$text
      
      predictions <- tryCatch(text_pred(statement), error = function(e) NULL)
      
      Table <- predictions[1:20, ]
      
      Prediction <- predictions[1, "Prediction"]
      
      
      return(list(Table = Table, Prediction = Prediction))
      
    }
  })
  
  condition_check <- reactive({ length(reactive_pred()[["Prediction"]]) })
  
  output$condition <- renderText({ condition_check() })
  
  outputOptions(output, 'condition', suspendWhenHidden = FALSE)
  
  
  ## Output Prediction
  output$Prediction = renderPrint({ 
    
    if(input$text != '') {
      
      output.statement <- reactive_pred()[["Prediction"]]
      if(length(output.statement) != 0) {
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
      
      # extract table
      prob_table <- reactive_pred()[["Table"]]
      
      # Set plot background
      par(bg = "#222222")
      
      # Create plot
      if(nrow(prob_table) != 0) {
        wordcloud(prob_table$Prediction, prob_table$Probability, colors = pal, fixed.asp = FALSE, rot.per = 0, random.order = FALSE, scale = c(8, 1))
      }
    }
  }, execOnResize = TRUE, width = 500, height = 500)
  
  ## Output Table
  output$Table <- renderTable({
    
    if(input$text != '') {
      probs_table <- reactive_pred()[["Table"]][1:10, ]
      probs_table
    }
  }, striped = TRUE, bordered = TRUE)
  
})
