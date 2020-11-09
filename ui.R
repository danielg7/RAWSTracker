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

library("semantic.dashboard")
library("leaflet")

choiceList <- c("Energy Release Component","Burning Index","Spread Component","KBDI","100 Hr FM","1000 Hr FM","10 Hr FM")
choiceValues <- names(data_clean)[13:19]
names(choiceValues) <- choiceList

header <- dashboardHeader(title = "RAWS Explorer",
                          disable = FALSE,
                          inverted = TRUE ,color = "black")
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(tabName = "map",
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

tab_map <- fluidRow(column(leafletOutput("map"), width = 12),
           tab_box(width = 12,
                   title = "Inputs & Graphs",
                   tabs = list(
                     list(menu = "Inputs",
                          content = selectInput(inputId = "input_fwvar",
                                               choices = choiceValues,
                                               selected = "ERC",
                                               label = "Select Variable To Map")),
                     list(menu = "Histogram",
                               content = plotOutput("fig_histogram", height = "300px")),
                     list(menu = "Time Series",
                          content = plotOutput("fig_timeseries",
                                               height = "300px")))))


tab_table <- fluidRow(
      dataTableOutput("table_selectedData")
)

aboutTab <- fluidRow(includeMarkdown("about.md")
  )


dashboard <- dashboardBody(
  tabItems(
    tabItem(tabName = "map", tab_map),
    tabItem(tabName = "table", tab_table),
    tabItem(tabname = "about",aboutTab))
)



ui <- dashboardPage(title = "RAWS Explorer",
                    header = header,
                    sidebar = sidebar,
                    body = dashboard,
                    suppress_bootstrap = FALSE
)


