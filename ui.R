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

library(shiny)
library("shinydashboard")
library("shiny.semantic")
library("semantic.dashboard")

choiceList <- c("Energy Release Component","Burning Index","Spread Component","KBDI","100 Hr FM","1000 Hr FM","10,000 Hr FM")
choiceValues <- names(data_clean)[13:19]

ui <- dashboardPage(title = "RAWS Explorer",
  dashboardHeader(title = "RAWS Explorer", disable = FALSE),
  dashboardSidebar(sidebarMenu(
    menuItem(tabName = "home", text = "Home", icon = icon("map")),
    menuItem(tabName = "another", text = "About", icon = icon("book"))
  )),
  dashboardBody( 
    fluidRow( 
      box(width = 8,
          height = 6,
          leafletOutput("map", height = 300)),
      box(plotOutput(
        "fig_histogram", height = 300
      )
      )
    ),
    fluidRow(
      box(width = 8, height = 6,
          plotOutput("fig_timeseries", height = 300)),
      box(width = 2,
          title = "Fire Weather Variable",
          dropdown_input(input_id = "input_fwvar",
                         choices = choiceList,
                         choices_value = choiceValues,
                         value = "ERC",
                         default_text = "Select Variable To Map"))
    )
  )
  )


