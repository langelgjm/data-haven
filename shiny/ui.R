library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Greater New Haven Survey Data"),

  # Drop down list with variable names sorted alphabetically
  sidebarLayout(
    sidebarPanel(
      selectInput("variable", "Variable", sort(names(dhr)))
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Map", plotOutput("map")),
        tabPanel("Histogram", plotOutput("hist")),
        tabPanel("Summary", tableOutput("summary"))
      )
    )
  )
))

