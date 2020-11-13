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

library("semantic.dashboard")
library("leaflet")
library("plotly")

# Download and Clean Data -------------------------------------------------



choiceList <<- c("Energy Release Component","Burning Index","Spread Component","KBDI","100 Hr FM","1000 Hr FM","10 Hr FM")
choiceValues <<- c("ERC","BI","SC","KBDI","Hun","Thou","Ten")
names(choiceValues) <<- choiceList

header <- dashboardHeader(title = "RAWS Explorer",
                          disable = FALSE,
                          inverted = TRUE ,color = "black")
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(tabName = "mapTab",
             text = "Home",
             icon = icon("map")),
    menuItem(tabName = "table",
             text = "Data Table",
             icon = icon("table")),
    menuItem(tabName = "about",
             text = "About",
             icon = icon("book"))
  )
)

mapTab <- tabItem(tabName = "mapTab", 
  fluidRow(leafletOutput("map"), width = 12),
  fluidRow(box(selectInput(inputId = "input_fwvar",
                           choices = choiceValues,
                           selected = "ERC",
                           label = "Select Variable To Map"), width = 8),
           tab_box(width = 8,
                   title = "Graphs",
                   tabs = list(
                     list(menu = "Time Series",
                          content = plotlyOutput("fig_timeseries",
                                               height = "300px")),
                     list(menu = "Histogram",
                          content = plotlyOutput("fig_histogram", height = "300px")))
                   )
           )
)


tab_table <- fluidRow(
      DT::dataTableOutput("table_selectedData")
)

aboutTab <- fluidRow(box(includeMarkdown("about.md"))
  )


dashboard <- dashboardBody(
  tabItems(
    mapTab,
    tabItem(tabName = "table", tab_table),
    tabItem(tabname = "about",aboutTab))
)



ui <- dashboardPage(title = "RAWS Explorer",
                    header = header,
                    sidebar = sidebar,
                    body = dashboard,
                    suppress_bootstrap = FALSE
)


