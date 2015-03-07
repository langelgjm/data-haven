library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Greater New Haven Survey Data"),

  # Drop down list with variable names sorted alphabetically
  sidebarLayout(
    sidebarPanel(
      #h1("Greater New Haven Survey Data", style="font-family: 'Trebuchet MS', Helvetica, sans-serif"),
      h3("How to use", style="font-family: 'Trebuchet MS', Helvetica, sans-serif"),
      p("Select a variable from the drop-down list, and the results on the right will update automatically. Click on the tabs to see different visualizations of the data."),
      selectInput("variable", "Variable", sort(names(dhr))),
      p("You can also compare groups by one of the following buttons:"),
      radioButtons("radio",
                         label = h4("Compare by...", style="font-family: 'Trebuchet MS', Helvetica, sans-serif"),
                         choices = list("None" = 0,
                                        "Gender" = 1,
                                        "Race" = 2,
                                        "Ring (always shown in map)" = 3),
                         selected = 0
                         ),
      h4("Sample sizes", style="font-family: 'Trebuchet MS', Helvetica, sans-serif"),
      tableOutput("samplesizes")
      ),

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Map",
                 p("This map shows differences in the average response by ring (City of New Haven, Inner Ring, and Outer Ring)."),
                 plotOutput("map")),
        tabPanel("Histogram",
                 p("The histogram shows the number of people providing a given response."),
                 plotOutput("hist")),
        tabPanel("Summary",
                 p("Summary statistics for the selected variable in the form of a boxplot:"),
                 plotOutput("boxplot"),
                 p("A crosstab for the selected variable and groups (if any):"),
                 tableOutput("crosstab"))
      )
    )
  )
))

