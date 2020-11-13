#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

#TODO
# Document
# Adjust map color
# Value specific histograms

#library("semantic.dashboard")
#library('shiny.semantic')
library("shinydashboard")
library("shinydashboardPlus")
library("leaflet")
library("plotly")

# Download and Clean Data -------------------------------------------------

print("Generating choice list...",quote = F)

choiceList <<- c("Energy Release Component","Burning Index","Spread Component","KBDI","10 Hr FM","100 Hr FM","1000 Hr FM")
choiceValues <<- c("ERC","BI","SC","KBDI","Ten","Hun","Thou")

names(choiceValues) <<- choiceList

print("Done.",quote = F)


header <- dashboardHeader(title = "RAWS Tracker")

sidebar <- 
  dashboardSidebar(
    sidebarMenu(
      menuItem(tabName = "mapTab",
               text = "Home",
               icon = icon("map")),
      menuItem(tabName = "table",
               text = "Data Table",
               icon = icon("table")),
      menuItem(tabName = "about_link",
               text = "About",
               icon = icon("book"))
    ),
    selectInput(inputId = "input_fwvar",
                choices = choiceValues,
                selected = "ERC",
                label =  "Select Variable To Map")
  )

tab_mainPanel <- 
  tabItem(tabName = "mapTab", 
          fluidRow(leafletOutput("map"), width = 12),
          fluidRow(tabBox(width = 12,
                          title = "Graphs",
                          tabPanel(title = "Time Series",
                                   plotlyOutput("fig_timeseries",
                                                height = "300px")),
                          tabPanel(title = "Histogram",
                                   plotlyOutput("fig_histogram",
                                                height = "300px")))
                   )
          )
  


tab_table <- tabItem(tabName = "table",
                     fluidRow(
                       DT::dataTableOutput("table_selectedData")
                       )
)

tab_about <- tabItem(tabName = "about_link",
                    fluidRow(box(width = 12,includeMarkdown("about.md"))
                    )
                    )


body <- dashboardBody(
  tabItems(
    tab_mainPanel,
    tabItem(tabName = "table", tab_table),
    tab_about)
)


ui <- dashboardPage(header = header,
                    sidebar = sidebar,
                    body = body
)


