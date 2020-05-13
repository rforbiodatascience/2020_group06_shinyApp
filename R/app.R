# Clear workspace --------------------------------------------------------------
rm(list = ls())

# Load libraries ---------------------------------------------------------------
library(shiny)
library(tidyverse)
library(deSolve)

# Load data --------------------------------------------------------------------
df <- read_csv(file = "SIR_df.csv")

df %>% filter(days_since_first >= 0)

SIR <- function(time,state,parameters) {
  with(as.list(c(state,parameters)), {
    dS = -beta*I*S / N
    dI = beta*I*S / N - gamma*I
    dR = gamma*I
    #dD = mu*I
    return(list(c(dS,dI,dR)))
  })
}

# Define UI for application ----------------------------------------------------

ui <- fluidPage(

   # Application title
   titlePanel("COVID-19 SIR modelling"),

   # Sidebar with a slider input for beta and gamma
   sidebarLayout(
      sidebarPanel(
         sliderInput("beta",
                     "Infection rate (beta):",
                     min = 0,
                     max = 1,
                     value = 0.50),
         sliderInput("gamma",
                     "Recovery rate (gamma):",
                     min = 0,
                     max = 1,
                     value = 0.50),
         selectInput("country","Country/region",
                     choices = df %>% select(region) %>% unique()),
         textOutput("R0")
      ),

      # Show generated plot of COVID-19 cases
      mainPanel(
        plotOutput("SIRplot")
      )
   )
)

# Define server logic ----------------------------------------------------------

server <- function(input, output) {

  output$R0 <- renderText({
    paste("Reproductive rate: (R0)", round(input$beta/input$gamma,2))
  })

  output$SIRplot <- renderPlot({

    df <- df %>% filter(region == input$country & days_since_first >= 0)


    #time points from first infection to latest date
    times <- seq(0,df %>%
                   filter(region == input$country) %>%
                   select(days_since_first) %>% max())

    #population size
    N <- df %>%
      select(N) %>%
      min()

    #for x axis limits
    max_days <- df %>%
      select(days_since_first) %>%
      max()

    #for y axis limits
    max_infected <- df %>%
      select(I) %>%
      max()

    #initial values for the ODEs
    initial_values <- c(
      S = N - 1,
      I = 1,
      R = 0
    )

    # solve ODEs
    df_fitted <- ode(y=initial_values,
                     times = times,
                     func = SIR,
                     parms = c(beta = input$beta,
                               gamma = input$gamma,
                               N = N)) %>%
      data.frame() %>%
      as_tibble()

    # wrangle the result
    df_result_long <- df %>%
      #join the observed and fitted values in one df
      full_join(df_fitted,
                by = c("days_since_first" = "time"),
                suffix = c("_observed","_fitted")) %>%
      #long format for plotting
      select(days_since_first,
             I_observed, I_fitted,
             R_observed, R_fitted) %>%
      pivot_longer(cols = -days_since_first,
                   names_to = "measure",
                   values_to = "value")

    # compare observed and predicted infections
    ggplot(df_result_long %>%
             filter(measure == "I_observed"
                    | measure == "I_fitted"),
           mapping = aes(x = days_since_first,
                         y = value,
                         group = measure,
                         color = measure)) +
      geom_point() +
      xlim(c(0,max_days)) +
      labs(title = "Active cases",
           subtitle = "Observed vs predicted",
           x = "Days since first infection",
           y = "Active infections",
           color = "Measure") +
      scale_color_manual(labels = c("Predicted", "Observed"),
                         values = c("#F8766D", "#619CFF"))   })

}

# Run the application ----------------------------------------------------------

shinyApp(ui = ui, server = server)

