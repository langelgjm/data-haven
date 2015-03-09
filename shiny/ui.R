library(shiny)
#TODO:
# pretty names for grouping variable levels
setwd("/Users/gjm/Documents/_Works in Progress/DataHaven/")
source("shiny/helpers.R")

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
      p("You can compare groups by one of the following buttons. Note that choosing Ring or Town will not affect the map; to change the map, select the appropriate option in the Geography section."),
      radioButtons("radio",
                         label = h4("Compare by", style="font-family: 'Trebuchet MS', Helvetica, sans-serif"),
                         choices = list("None" = 0,
                                        "Gender" = 1,
                                        "Race" = 2,
                                        "Ring" = 3,
                                        "Town" = 4),
                         selected = 0
                         ),
      radioButtons("radio_geo",
                   label = h4("Geography", style="font-family: 'Trebuchet MS', Helvetica, sans-serif"),
                   choices = list("Ring" = 1,
                                  "Town (for demonstration only)" = 2),
                   selected = 1
      ),
      p("Note that town geography is included for demonstration purposes only; cell sizes are too small to draw meaningful inferences."),
      h4("Sample sizes", style="font-family: 'Trebuchet MS', Helvetica, sans-serif"),
      tableOutput("samplesizes")
      ),

    mainPanel(
      tabsetPanel(
        tabPanel("Map",
                 p("This map shows differences in the average response by geography (ring or town)."),
                 plotOutput("map")),
        tabPanel("Histogram",
                 p("Histograms show the number of people providing a given response."),
                 plotOutput("hist")),
        tabPanel("Boxplot",
                 p("Summary statistics for the selected variable in the form of a boxplot. The heavy vertical line reports the median value, and the box ranges from the first quartile to the third quartile. The whiskers extend to the minimum and maximum, excluding outliers, which are plotted as dots."),
                 plotOutput("boxplot"),
                 p("Visual explanation of a boxplot:"),
                 img(src="boxplot_explained.png")),
        tabPanel("Table",
                p("A table showing the proportion of respondents falling into various cells."),
                radioButtons("radio_table",
                             label = h4("View proportions...", style="font-family: 'Trebuchet MS', Helvetica, sans-serif"),
                             choices = list("Within groups (default)" = 2,
                                            "Across groups" = 1,
                                            "Within and across groups" = 0
                                            ),
                             selected = 2
                ),
                tableOutput("crosstab"))
        )
      )
    )
))

