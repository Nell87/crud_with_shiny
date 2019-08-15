
#### 0.   INCLUDES ________________________________________________________ #### 

#Load Libraries: p_load can install, load,  and update packages
if(require("pacman")=="FALSE"){
  install.packages("pacman")
}

pacman::p_load(rstudioapi,dplyr, ggplot2, lubridate, randomForest, caret,
               rpart,rpart.plot,tidyr, shiny, shinydashboard, rvest, DT,
               ggthemes,RMySQL,rhandsontable,data.table,shinyjs,DBI, shinyBS)

# Setwd (set current wd where is the script, then we move back to the
# general folder)
current_path = getActiveDocumentContext()$path
setwd(dirname(current_path))
setwd("..")
rm(current_path) 

#### 1.   PREPARING DATA: SQL _____________________________________________ #### 
source("./scripts/credentials.R")
mydb = dbConnect(MySQL(), user=user, password=password, 
                 dbname=dbname, host=host, port=port)

dbListTables(mydb)

recipes = fetch(dbSendQuery(mydb, "select * from recipes"))
sources = fetch(dbSendQuery(mydb, "select * from sources"))
ingredients = fetch(dbSendQuery(mydb, "select * from ingredients"))



# newline<- data.frame(id=4, name="patata", id_sources=2, url="pa", 
#                                minutes=60, temperature="caliente")
# 
# DBI::dbWriteTable(mydb, name="recipes", value=newline, append=TRUE,
#                   row.names = FALSE)



#### 2. SHINY _____________________________________________________________ #### 


ui <- dashboardPage(
  dashboardHeader(title = "Playig with the database"),
  
  # Sidebar 
  dashboardSidebar(
    sidebarMenu(
      menuItem("Exploring", tabName = "exploring", icon =icon("table")),
      menuItem("Adding", tabName = "adding", icon =icon("plus-circle"))
    )
  ),
      
  dashboardBody(
    tabItems(
      
      tabItem(tabName = "exploring",  
              column(12,
                  title = "",rHandsontableOutput("exploring"))),
      
      tabItem(tabName = "adding",
               
             fluidRow(rHandsontableOutput("adding")),
             fluidRow(
               column(6,
                 textInput(inputId = "recipe_insert_name", label= "Insert name", value=""),
                 selectInput(inputId = "recipe_select_source", label= "Insert source",
                             choices = c(1,2)),
                 textInput(inputId = "recipe_insert_url", label= "Insert url", value="")
                 
               ),
               column(6,
                 numericInput(inputId = "recipe_insert_time", label="Insert time", value=""),
                 selectInput(inputId = "recipe_select_temp", label= "Insert source",
                             choices = c("fria", "caliente")),
                 selectizeInput(inputId = "recipe_select_ingred", 
                                label= "Insert main ingredients",
                                choices= c(ingredients$name),selected = NULL, 
                                multiple = TRUE)
               )
                   
             ),
             
             fluidRow(
               column(6,
                actionButton("save","save")
               ),
               column(6,
                # Restart the shiny session
                tags$a(href="javascript:history.go(0)", 
                       popify(tags$i(class="fa fa-refresh fa-5x"),
                              title = "Reload", 
                              content = "Click here to restart the Shiny session",
                              placement = "right"))      
               )
             )
      )
    )
  )
)
 server <- function(input, output, session) {
 
   #### PREPARING DATA _____________________________________________####     
    
   # Connect to databse
   mydb <- reactive({
     mydb = dbConnect(MySQL(), user=user, password=password, 
                      dbname=dbname, host=host, port=port)
   })
   
   # RecipeS
   recipes<- reactive({
      recipes = fetch(dbSendQuery(mydb(), "select * from recipes"))
   })
   
   #### OUTPUTS ____________________________________________________________####
   
   # Showing the exploring section
   output$exploring = renderRHandsontable({
     rhandsontable(recipes())   
   })
   
   # Showing the adding section
   output$adding = renderRHandsontable({
     rhandsontable(recipes()) 
   })
   
   # Saving the changes with the save button
   observeEvent(input$save,{

    newline<- data.frame(name=input$recipe_insert_name,
                          id_sources=input$recipe_select_source,
                          url=input$recipe_insert_url,
                          minutes= input$recipe_insert_time,
                          temperature=input$recipe_select_temp)
    mydb = mydb()
    DBI::dbWriteTable(mydb, name="recipes", value=newline, append=TRUE,
                       row.names = FALSE)

   })

 }

 shinyApp(ui, server) 
 