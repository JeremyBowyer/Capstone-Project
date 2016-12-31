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
  
  conditionalPanel(condition="output.condition != '0' ",
    div(
      div(
      tableOutput("Table"),
      style = "display: inline-block; vertical-align: top;"
      ),
      
      div(
      plotOutput("WordCloud", width = "100%"),
      style = "display: inline-block; vertical-align: top;"
      ),
      style = "width: 70%; margin: 0 auto;"
    )
  )
))
