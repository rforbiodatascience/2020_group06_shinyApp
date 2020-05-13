# 2020_group06_shinyApp
Shiny: SIR Modelling

## Sule Altintas, Sebastian Sbirna and Stanley Frederiksen

## Description

This Shiny app allows the user to play around with SIR epidemiology modelling of COVID-19 data by adjusting the infection rate $\beta$ and recovery rate $\gamma$, choosing from a multitude of countries and provinces for the initial values. The predicted incidence curve will be shown along with the observed incidences for a given country.


## Data

The raw data was originally obtained from Kaggle:

https://www.kaggle.com/sudalairajkumar/novel-corona-virus-2019-dataset

The wrangling steps to get the table in app/data are documented in our other repo on COVID-19 modelling:

https://github.com/rforbiodatascience/2020_group06

## Dependencies

- [R](https://cran.r-project.org/bin/windows/base/) >= 4.0.0, and the following additional packages:
  * __shiny__
  * __tidyverse__
  * __deSolve__

