#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library("shiny")
library("googlesheets4")
#library("shiny.semantic")
#library('semantic.dashboard')
library("shinydashboard")
library("shinydashboardPlus")
library("tidyverse")
library("dplyr")
library("leaflet")
library("cowplot")
library("DT")
library("plotly")

Sys.setlocale('LC_ALL','C')


# Update data if it hasn't been updated.

if(!exists(x = "download")){
  gs4_deauth()
  download <- read_sheet(ss = "https://docs.google.com/spreadsheets/d/1S8HrkXON716VVnf6WLre6uPTAIm_aPVkOtDQZAUH-Y8/edit?usp=sharing",sheet = "FinalRecord")
  data_clean <- filter(download,
                       Lat <= 45, Long > -110)
  data_clean$clicked <- "FALSE"
  mostRecentData <- filter(data_clean,
                           Date == max(Date))
} 
  



# Create a color palette for visualization
pal <- colorNumeric(palette = "YlOrBr", domain = NULL, reverse = FALSE)
clickPal <- colorFactor(palette = c("Red","Gray75"),domain = NULL, levels = c("TRUE","FALSE"))

shinyServer(function(input, output) {

  
  # Create a dataframe of only the most recent data.
  
  # Create reactive values for clicked markers
  data_of_click <- reactiveValues(clickedMarker = "REDFEATHER")
  
  # Primary map
  output$map <- renderLeaflet({
    leaflet() %>% addProviderTiles(provider = "Stamen.Terrain") %>%
      setView(lng = -106.3, lat = 36.07, zoom = 5.2)%>%
      addCircleMarkers(data = mostRecentData,
                       ~Long,
                       ~Lat,
                       layerId = ~Name,
                       radius = 5,
                       stroke = TRUE, weight = 2,
                       fillOpacity = .8,
                       color = ~clickPal(clicked),
                       label = ~Name,
                       labelOptions = labelOptions(noHide = F),
                       fillColor = ~pal(ERC))
  })

  # Check for marker click and update map
  observeEvent(input$map_marker_click, { 
    p <- input$map_marker_click 
    data_of_click$clickedMarker <- p$id
    
    mostRecentData$clicked <- "FALSE"
    data_clean$clicked <- "FALSE"
    
    
    mostRecentData[which(mostRecentData$Name == p$id),]$clicked <- "TRUE"
    data_clean[which(data_clean$Name == p$id),]$clicked <- "TRUE"
    
    leafletProxy("map", data = mostRecentData) %>%
      clearMarkers() %>%
      clearControls() %>%
      addCircleMarkers(data = mostRecentData,
                       ~Long,
                       ~Lat,
                       radius = 5,stroke = TRUE, weight = 2,
                       fillOpacity = .8,
                       color = ~clickPal(clicked),
                       label = ~Name,
                       layerId = ~Name,
                       labelOptions = labelOptions(noHide = F),
                       fillColor = ~pal(eval(as.symbol(input$input_fwvar)))) %>%
      addLegend(data = mostRecentData,
                pal = pal, 
                values = ~eval(as.symbol(input$input_fwvar)),
                title = choiceList[match(x = input$input_fwvar,table = choiceValues)])
  })
  
  observe({
    leafletProxy("map", data = mostRecentData) %>%
      clearMarkers() %>%
      clearControls() %>%
      addCircleMarkers(data = mostRecentData,
                       ~Long,
                       ~Lat,
                       radius = 5,stroke = TRUE, weight = 2,
                       fillOpacity = .8,
                       color = ~clickPal(clicked),
                       label = ~Name,
                       layerId = ~Name,
                       labelOptions = labelOptions(noHide = F),
                       fillColor = ~pal(eval(as.symbol(input$input_fwvar)))) %>%
      addLegend(data = mostRecentData,
                pal = pal, 
                values = ~eval(as.symbol(input$input_fwvar)),
                title = choiceList[match(x = input$input_fwvar,table = choiceValues)])
  })
  
  output$fig_histogram <- renderPlotly({
    if (isTruthy(input$map_bounds)) {
      bounds <- input$map_bounds
      toPlot <- mostRecentData %>% filter(
        between(Long, bounds$west, bounds$east),
        between(Lat, bounds$south, bounds$north)
      )
    } else
      toPlot <- mostRecentData
    
    
    
      ggplotly(tooltip = 'text',
    ggplot(data = toPlot,
           aes(x = eval(as.symbol(input$input_fwvar))))+
      geom_histogram(binwidth = 1,fill = "gray50",color = "black",
                     aes(text = paste(input$input_fwvar,' :',eval(as.symbol(input$input_fwvar)),sep="")
                         )
                     )+
      geom_vline(data = filter(mostRecentData, Name == data_of_click$clickedMarker,),
                 aes(xintercept = eval(as.symbol(input$input_fwvar))),
                 color = "red")+
      labs(title = paste("Frequency histogram of ", data_of_click$clickedMarker,"\n relative to all visible stations",sep = ""),
           subtitle = mostRecentData$Date[1])+
      scale_x_continuous(name = choiceList[match(x = input$input_fwvar,table = choiceValues)])+
      theme_cowplot()
    )
    
  })
  
  output$fig_timeseries <- renderPlotly({
    
    
      ggplotly(tooltip = 'text',
    
    ggplot(data = filter(data_clean, Name == data_of_click$clickedMarker), aes(x = Date,
                                  y = eval(as.symbol(input$input_fwvar))))+
      labs(title = paste("Time series of ", data_of_click$clickedMarker,sep = ""),
           subtitle = paste("Last recorded: ",mostRecentData$Date[1],sep=""))+
      geom_smooth(method = stats::loess)+
      geom_point(aes(text = paste('<br>Date: ',as.character(Date),'<br>',input$input_fwvar,' :',eval(as.symbol(input$input_fwvar)),sep="")))+
      scale_x_datetime(date_labels = "%Y-%m-%d")+
      scale_y_continuous(name = choiceList[match(x = input$input_fwvar,table = choiceValues)])+
      theme_cowplot()
      ) %>%
      layout( 
        xaxis = list(automargin=TRUE), 
        yaxis = list(automargin=TRUE)
      )
  })
  
  output$table_selectedData <- DT::renderDataTable({
    filter(data_clean, Name == data_of_click$clickedMarker) %>%
      select(-clicked)
  })
  
})
