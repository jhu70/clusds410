#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


# Packages ----
library(shiny)
library(shinydashboard)
library(leaflet) 
library(ggplot2)
library(shiny)



## FILES YOU NEED TO RUN BEFORE HAND:
## providers_in_polygons.Rmd
## Capacity Map FINAL.Rmd
## Hours_Supply_Maps_by_tract.Rmd
## Hours Demand Maps FINAL.Rmd


header <- dashboardHeader()
sidebar <- dashboardSidebar()
body <- dashboardBody()

ui <- dashboardPage(header, sidebar, body)

server <- function(input, output)  {}

#shinyApp(ui, server)



## HEADER

header <- dashboardHeader(
  title = "CLU: Childcare",
  dropdownMenu(type = "messages",
               messageItem(
                 from = "Community Labor United",
                 message = "Contact us for more information",
                 href = "http://massclu.org/about/"
               )),
  dropdownMenu(type = "notifications",
               notificationItem(
                 text = "CLU: Care That Works",
                 href = "http://massclu.org/initiatives/#childcare"
               ),
               notificationItem(
                 text = "Childcare Aware",
                 href = "https://www.childcareaware.org/"
               ))
)



## SIDEBAR

sidebar <- dashboardSidebar(
  sidebarMenu(
    
    ## INRODUCTION
    
    menuItem("Introduction",
             tabName = "introduction"),
    
    ## CAPACITY
    
    menuItem("Capacity",
             tabName = "capacity"
    ),
    
    ## HOURS
    
    menuItem("Hours",
             tabName = "hours"
    ),
    
    ##MEHODOLOGY
    
    menuItem("Methodology",
             tabName = "methodology")
  )
)

## BODY

body <- dashboardBody(
  tabItems(
    
    ## INTRODUCTION
    
    tabItem(tabName = "introduction",
            title = "Introduction",
            tags$h1("Community Labor United - Childcare"),
            tags$br(),
            tags$em("Community Labor United is a non-profit organization that is currently working to investigate the negligence in childcare provision for low and middle-income families within the Greater Boston Area, in order to promote reforms within the current system provided by the Department of Early Education and Care. "),
            tags$br(),
            tags$br(),
            tags$br(),
            tags$strong("Overview:"),
            tags$br(),
            tags$br(),
            p("Using interactive maps, the research outlined in this paper highlights two gaps in the current childcare structure:"),
            tags$div(tags$ul(
              tags$li("The first being how the hours that early education childcare providers keep do not support families that work primarily nonstandard schedules."),
              tags$li("The second being how the number of slots for early education provision does not align with the number of children age five and under that live within each neighborhood and census tract."),
              style = "font-size: 15px"),
              p("The interaction between these two gaps drastically impacts the livelihood of working class families and it is our hope that this research will provide evidence that the current system in place needs to be reconstructed, in order to support all households in Massachusetts."),
              p("This research emphasizes early education childcare demands needed for low and middle-income families working nonstandard hours in the Great Boston Area. More specifically, this research focuses on illustrating a disparity in operating hours and capacity for childcare providers on the neighborhood level and census tract level.")
            )
    ),
    
    ## CAPACITY
    
    # tabItem(tabName = "capacity",
    #         tags$h1("Number of children under 6 with all parents in the labor
    #                 force, per tract"),
    #         tags$br(),
    #         leafletOutput("laborforce_demand"),
    #         tags$br(),
    #         tags$h1("Number of slots for Early Education Providers, per tract"),
    #         leafletOutput("slots_supply"),
    #         tags$h1("Ratio of Number of Children to Avaliable Number of Slots, per neighborhood"),
    #         leafletOutput("ratioslots_gap"),
    #         tags$br(),
    #         tags$br(),
    #         plotOutput("all_neighborhoods_bar"),
    #         tags$br(),
    #         tags$br(),
    #         plotOutput("top_5_neighborhoods_bar")
    #         ),
    
    tabItem(tabName = "capacity",
            tags$h1("Early Ed Childcare Slots to Childcare Needs Comparison"),
            tags$br(),
            tags$br(),
            fluidRow(
              box(
                width = 6,
                title = "Children Under 6 Who Need Childcare",
                em("(per tract)"),
                br(),
                leafletOutput("laborforce_demand"),
                status = "danger"
              ),
              box(
                width = 6,
                title = "Childcare Slots for Early Education Providers",
                em("(per tract)"),
                br(),
                leafletOutput("slots_supply"),
                status = "danger"
              )
            ),
            tags$h1("Ratio of Number of Children to Available Number of Slots"),
            tags$em("(per neighborhood)"),
            fluidRow(
              box(
                width = 7,
                leafletOutput("ratioslots_gap"),
                status = "danger"),
              box(
                width = 5,
                plotOutput("ratioslots_bar"),
                status = "danger"
              )
            )
    ),
    
    ## HOURS
    
    tabItem(tabName = "hours",
            tags$h1("Percent of People Who Work Nonstandard Hours (per tract)"),
            tags$br(),
            tags$br(),
            fluidRow(
              box(
                width = 4,
                title = "Workers with Early Morning Shifts",
                em("leaving home between 12:00am - 6:59am"),
                em(" "),
                br(),
                leafletOutput("percent_early"),
                status = "danger"
              ),
              box(
                width = 4,
                title = "Workers with Early Evening Shifts",
                em("leaving home between 11:00am - 3:59pm"),
                em(" "),
                br(),
                leafletOutput("percent_evening"),
                status = "danger"
              ),
              box(
                width = 4,
                title = "Workers with Late Evening & Overnight Shifts",
                em("leaving home between 4:00pm - 11:59pm"),
                em(" "),
                br(),
                leafletOutput("percent_overnight"),
                status = "danger"
              )
            ),
            tags$h1("Nonstandard Hours Demand"),
            fluidRow(
              box(
                width = 8,
                leafletOutput("aggregate_percent"),
                status = "danger"),
              box(
                width = 4,
                em("The aggregated percentage is the sum of the percentage of people with all nonstandard hours (Monday - Friday, 7:30am - 6:00pm)."),
                p("------"),
                em(" Each dot is a childcare provider. You can hover over each childcare provider to see the number of slots they have available for off-hour weekday care."),
                status = "danger"
              )
            )
    ),
    
    ## METHODOLOGY
    
    tabItem(tabName = "methodology",
            fluidRow(
              column(width = 12,
                     box(
                       title = "Capacity",
                       width = NULL,
                       solidHeader = TRUE, 
                       collapsible = TRUE,
                       collapsed = FALSE,
                       status = "info",
                       tags$h4("Percent of Children Under 6 with all parents in
                               the labor force"),
                       em("This demand variable was created using information provided by 
                          the 2016 American Community Survice data, which we accessed through tidycensus in R."),
                       br(),
                       br(),
                       p("Wtihin the ACS data, there were three distinct variables that recorded number of parents
                         in the labor force with children under 6 for each census tract in the Boston area. 
                         One of the variables (B23008_004) gave us the parents in the labor force that came from a 
                         2-parent household, while the other two variables (B23008_010, B23008_013) gave us the parents
                         in the labor force that came from a 1-parent household. Using this information, we were to get
                         the total sum of all children with all parents in the labor force. Using the ACS data, we then 
                         extracted the total number of children under 6 per tract (B23008_002).",
                         style = "font-family: 'times'; font-si16pt"),
                       strong("We were able to find the percent of children under 6 with all parents in the labor 
                              force per tract, by taking the sum of children with all parents in the labor force over 
                              the estimated _______.",
                              style = "font-family: 'times'; font-si16pt"),
                       br(),
                       tags$h4("Capacity for Early Education Providers"),
                       em("This supply variable was created using the EEC dataset given to us by Community Labor United."),
                       br(),
                       br()
                       ),
                     box(
                       title = "Hours",
                       width = NULL,
                       solidHeader = TRUE,
                       collapsible = TRUE,
                       collapsed = TRUE,
                       status = "info",
                       p("p creates a paragraph of text."),
                       p("A new p() command starts a new paragraph. Supply a style
                         attribute to change the format of the entire paragraph.",
                         style = "font-family: 'times'; font-si16pt"),
                       strong("strong() makes bold text."),
                       em("em() creates italicized (i.e, emphasized) text."),
                       br(),
                       code("code displays your text similar to computer code"),
                       div("div creates segments of text with a similar style. This
                           division of text is all blue because I passed the argument
                           'style = color:blue' to div", style = "color:blue"),
                       br(),
                       p("span does the same thing as div, but it works with",
                         span("groups of words", 
                              style = "color:blue"),
                         "that appear inside a paragraph.")
                       )
                     )
                       ))
    )
)


## UI 

ui <- dashboardPage(skin = "purple",
                    header = header,
                    sidebar = sidebar,
                    body = body
)
## SERVER

server <- function(input, output) {
  ## CAPACITY
  output$laborforce_demand <- renderLeaflet({
    leaflet(neighborho_demand_tract) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_laborforce(laborforce),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, stroke=TRUE, color="black", label=~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11) %>%
      addLegend("topleft", 
                pal = pal_laborforce, 
                values = ~laborforce,
                opacity = 1,
                title="# Children")
  })
  
  output$slots_supply <- renderLeaflet({
    leaflet(neighborho_capacity_tract) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_slots(slots),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, 
                  stroke = TRUE, 
                  color = "black", 
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11) %>%
      addLegend("topleft", 
                pal = pal_slots, 
                values = ~slots,
                opacity = 1,
                title = "# Slots")
  })
  
  output$ratioslots_gap <- renderLeaflet({
    leaflet(EEC_census) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_ratioslots(ratioslots),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, 
                  stroke = TRUE, 
                  color = "black", 
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11.5) %>%
      addLegend("topleft", 
                pal = pal_ratioslots, 
                values = ~ratioslots,
                opacity = 1,
                title = "Ratio Slots")
  })
  
  output$ratioslots_bar <- renderPlot({
    ggplot(EEC_census_bar, aes(x = reorder(Name_neighborho,ratioslots), y = ratioslots)) +
      geom_bar(fill = "blue", 
               stat = "identity") + 
      ggtitle( "Childcare Ratio by Neighborhood") + 
      xlab("Neighborhoods") +  
      ylab("Children Under 6 to Available Early Ed Slots Ratio") +
      geom_hline(yintercept=1) +
      coord_flip()
  })
  ## HOURS
  output$percent_early <- renderLeaflet({
    leaflet(hours_demand) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_early(percent_early),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, stroke = TRUE, 
                  color = "black", 
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11.5) %>%
      addLegend("topleft", 
                pal = pal_early, 
                values = ~percent_early,
                opacity = 1,
                title = "% Early Workers")
  })
  
  output$percent_evening <- renderLeaflet({
    leaflet(hours_demand) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_evening(percent_evening),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, 
                  stroke = TRUE, 
                  color = "black", 
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11.5) %>%
      addLegend("topleft", 
                pal = pal_evening, 
                values = ~percent_evening,
                opacity = 1,
                title = "% Evening Workers")
  })
  
  output$percent_overnight <- renderLeaflet({
    leaflet(hours_demand) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_overnight(percent_overnight),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, 
                  stroke = TRUE, 
                  color = "black", 
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11.5) %>%
      addLegend("topleft", 
                pal = pal_overnight, 
                values = ~percent_overnight,
                opacity = 1,
                title = "% Overnight Workers")
  })
  
  output$aggregate_percent <- renderLeaflet({
    leaflet(hours_demand) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_aggregate_percent(aggregate_percent),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, 
                  stroke = TRUE, 
                  color = "black",
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11.5) %>%
      addCircleMarkers(data = EEC_earlyed,
                       ~lon,
                       ~lat,
                       radius = 2.5,
                       opacity = 1,
                       color = ~infant_pal(Weekdays_off_hours),
                       label = ~as.character(Capacity),
                       group= "Show childcare providers with off hours weekday care") %>%
      addLayersControl(overlayGroups = c("Show childcare providers with off hours weekday care")) %>%
      addLegend("topleft", 
                pal = pal_aggregate_percent, 
                values = ~aggregate_percent,
                opacity = 1,
                title="Aggregated Percentage")
  })
}

## SHINYAPP

shinyApp(ui, server)



