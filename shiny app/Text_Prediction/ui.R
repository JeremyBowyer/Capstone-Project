library(shiny)
library(shinythemes)

# Create Navbar UI for App
shinyUI(navbarPage(title = "Text Prediction Application",
                   theme = shinytheme("slate"),
                   fluid = TRUE,
                   tabPanel("About",
                            mainPanel(includeHTML("About.html"))),
                   tabPanel("Application",
  # Create divs to allow for custom formatting of app
  div(
      div(
        textInput("text", label = h1("Text Prediction", style = "color: #222222"), value = "", placeholder = "Type a phrase..."),
        textOutput("Prediction", inline = TRUE),
        style = "display: inline-block;"
      ),
      style = "height:175px;text-align:center;"
  ),
  hr(),
  
  # Create conditional panel, only revealed if there are predictions to display
  conditionalPanel(condition="output.condition != '0' ",
    # Divs to manually format the resulting table and word cloud
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
)))
