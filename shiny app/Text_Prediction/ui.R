library(shiny)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("darkly"),
                  
  div(
      div(
        # Copy the line below to make a text input box
        textInput("text", label = h1("Text Prediction", style = "color: #778899"), value = "", placeholder = "Type a phrase..."),
        textOutput("Prediction", inline = TRUE),
        style = "display: inline-block;"
      ),
      style = "background-color:#171b1e;height:175px;text-align:center;"
  ),
  
  conditionalPanel(condition="input.text!=''",
    div(
      div(
      tableOutput("Table"),
      style = "position:absolute;top:50px;left:650px;"
      ),
      
      div(
      plotOutput("WordCloud", width = "100%"),
      style = "position:absolute;right:500px;"
      ),
      style = "position: relative;"
    )
  )
))
