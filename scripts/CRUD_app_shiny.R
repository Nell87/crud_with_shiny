
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

#### 2. SHINY _____________________________________________________________ #### 

ui <- dashboardPage(
  dashboardHeader(title = "Playing with the database"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Exploring", tabName = "exploring", icon =icon("table")),
      menuItem("Adding", tabName = "adding", icon =icon("plus-circle"),
               startExpanded = TRUE,
               menuSubItem("recipes", tabName = "recipes"),
               menuSubItem("sources", tabName = "sources"),
               menuSubItem("ingredients", tabName = "ingredients"),
               menuSubItem("testing", tabName = "testing")
               )
    )
  ),
      
  dashboardBody(
    tabItems(
      
      # Exploring 
      tabItem(tabName = "exploring",  
              column(12,
                  title = "",DT::dataTableOutput("exploring"))),
      
      # Inserting recipes      
      tabItem(tabName = "recipes",
               
             fluidRow(DT::dataTableOutput("adding_recipes_table")),
             fluidRow(
               column(6,
                 textInput(inputId = "recipe_insert_name", label= "Insert name", value=""),
                 selectInput(inputId = "recipe_select_source", label= "Insert source",
                             choices= c(as.list(fetch(dbSendQuery(mydb, "select name from sources")))[[1]])),
                 textInput(inputId = "recipe_insert_url", label= "Insert url", value="")
                 
               ),
               column(6,
                 numericInput(inputId = "recipe_insert_time", label="Insert time", value=""),
                 selectInput(inputId = "recipe_select_temp", label= "Insert source",
                             choices = c("fria", "caliente")),
                 selectizeInput(inputId = "recipe_select_ingred", 
                                label= "Insert main ingredients",
                                choices= c(as.list(fetch(dbSendQuery(mydb, "select name from ingredients")))[[1]]),
                                selected = NULL, 
                                multiple = TRUE)
               )
                   
             ),
             
             fluidRow(
               column(6,
                actionButton(label="save",inputId = "save_recipe")
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
      ),
      
      # Inserting sources         
      tabItem(tabName = "sources",
              fluidRow(DT::dataTableOutput("adding_sources_table")),
              fluidRow(
                 textInput(inputId = "source_insert_name", label= "Insert new source", value=""),
                 actionButton(label="save",inputId="save_source")
              )
      ),

      # Inserting ingredients            
      tabItem(tabName = "ingredients",
              fluidRow(DT::dataTableOutput("adding_ingredients_table")),
              fluidRow(
                 textInput(inputId = "ingredient_insert_name", label= "Insert new ingredient", value=""),
                 actionButton(label="save", inputId = "save_ingredient")
              )
      ),
       tabItem(tabName = "testing", dataTableOutput("testing2")
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
   output$exploring = renderDataTable({
     recipes() 
   })
   
   # Showing the adding section for recipes
   output$adding_recipes_table = renderDataTable({
     recipes()
   })

   # Saving the changes with the save_recipes button
   observeEvent(input$save_recipe,{
     
        # REFRESH DATA
        mydb = mydb()
       
        sources = fetch(dbSendQuery(mydb(), "select * from sources"))
        ingredients = fetch(dbSendQuery(mydb(), "select * from ingredients"))
        
        id_sources= sources$id[sources$name==input$recipe_select_source]
        id_ingredients<-c()
        id_ingredients<-append(id_ingredients,ingredients$id[ingredients$name %in% input$recipe_select_ingred])
        
        
        # RECIPES
        newline_recipes<- data.frame(name=input$recipe_insert_name,
                              id_sources=id_sources,
                              url=input$recipe_insert_url,
                              minutes= input$recipe_insert_time,
                              temperature=input$recipe_select_temp)

        DBI::dbWriteTable(mydb, name="recipes", value=newline_recipes, 
                          append=TRUE, row.names = FALSE)
        
        # RELACIONAL TABLE
        recipes = fetch(dbSendQuery(mydb(), "select * from recipes"))
        id_recipes = id_recipes= recipes$id[recipes$name==input$recipe_insert_name]
        newline_rel<- data.frame(id_ingredients=id_ingredients)
        newline_rel<- newline_rel %>% mutate(id_recipes = id_recipes)
        # newline_rel<- data.frame(id_ingredients=c(3,4),id_recipes=c(1,1))

        DBI::dbWriteTable(mydb, name="rel_ingredients_recipes", value=newline_rel, 
                          append=TRUE,row.names = FALSE)
    
    
   })
    
    # Saving the changes with the save_sources button
    observeEvent(input$save_source,{

       newline<- data.frame(name=input$source_insert_name)
       mydb = mydb()
       DBI::dbWriteTable(mydb, name="sources", value=newline, append=TRUE,
                         row.names = FALSE)
       
       updateSelectInput(session, "recipe_select_source",
                         choices= c(as.list(fetch(dbSendQuery(mydb, "select name from sources")))[[1]]))

       output$adding_sources_table = renderDataTable({
          sources = fetch(dbSendQuery(mydb(), "select * from sources"))

       })
   })
    
    # Saving the changes with the save_sources button
    observeEvent(input$save_ingredient,{
       
       newline<- data.frame(name=input$ingredient_insert_name)
       mydb = mydb()
       DBI::dbWriteTable(mydb, name="ingredients", value=newline, append=TRUE,
                         row.names = FALSE)
       
       updateSelectizeInput(session, "recipe_select_ingred",
                         choices= c(as.list(fetch(dbSendQuery(mydb, "select name from ingredients")))[[1]]))
       
       output$adding_ingredients_table = renderDataTable({
          ingredients = fetch(dbSendQuery(mydb(), "select * from ingredients"))
          
       })
       
   
    })
    
     output$testing2<- renderDataTable({
       ingredients = fetch(dbSendQuery(mydb(), "select * from ingredients"))
       
       id_ingredients2<-c()
       id_ingredients2<-append(id_ingredients2,ingredients$id[ingredients$name %in% input$recipe_select_ingred])
       testing<- data.frame(id_ingredients=id_ingredients2)
       id_recipes=2
       testing<- testing %>% mutate(id_recipes = id_recipes)


     })
    

 }

 shinyApp(ui, server) 
 