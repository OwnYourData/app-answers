# global constants available to the app
# last update: 2017-06-11

# required Libraries
library(shiny)
library(shinyjs)
library(shinyBS)
library(rintrojs)
library(sodium)
library(oydapp)
library(shinyAce)
library(shinyWidgets)
library(dplyr)

# sources for user specific UI
source('uiBody.R')

# constants required for every app
appName <- 'answers'
appTitle <- 'Questions & Answers'
app_id <- 'oyd.answers'
appRepoDefault <- 'oyd.settings'
helpUrl <- 'https://www.ownyourdata.eu/apps/answers'

# console logging
oydLog <- function(msg)
        cat(paste(Sys.time(), msg, "\n"))
oydLog('App start')

# Version information
currVersion <- "0.3.0"
verHistory <- data.frame(rbind(
        c(version = "0.3.0",
          text    = "erstes Release")
))

# translations for app specific localizations
localization <- list(
        'ctrlTrnsl_appTitle' = list('de' = 'Fragen & Antworten', 
                                    'en' = 'Questions & Answers'),
        'missingKey' = list('de' = 'Fehlendes Passwort',
                            'en' = 'Missing Key'),
        'missingKeyInfo' = list('de' = 'Es fehlt das Passwort zum Entschlüsseln deiner Daten! Verwende das Menu "Einstellungen" rechts oben, um das Passwort einzugeben.',
                                'en' = 'The key to decrypt your data is missing! Use the settings menu in the upper right corner, to enter the key.')
)
