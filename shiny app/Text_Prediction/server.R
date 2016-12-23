library(shiny)
library(tm)
library(stringi)
library(RWeka)
library(stringr)
library(quanteda)
library(rJava)
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
  
  ## Output Prediction
  output$Prediction = renderPrint({ 
    
    if(input$text != '') {
    
      output.statement <- reactive_pred()[["Prediction"]]
      as.character(output.statement) 
      
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
      wordcloud(prob_table$Prediction, prob_table$Probability, colors = pal, fixed.asp = FALSE, rot.per = 0, random.order = FALSE, scale = c(8, 1))
      
    }
  }, execOnResize = TRUE, width = 500, height = 500)
    
  ## Output Table
  output$Table <- renderTable({
    
    if(input$text != '') {
      
      reactive_pred()[["Table"]][1:10, ]
      
    }
  }, striped = TRUE, bordered = TRUE)

})
