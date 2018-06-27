```{r, echo=FALSE, out.width="100%"}
library(shiny)
tags$div(tags$strong("Pollen", class="col-xs-3"), tags$div(
        selectInput("pollination", label = span("Pollen", style="display:none;"), 
                    choices = list(
                            "Beifuß (Artemisia)" = "artemisia",
                            "Birke (Betula)" = "betula",
                            "Erle (Alnus)" = "alnus",
                            "Esche (Fraxinus)" = "fraxinus",
                            "Gräser (Poaceae)" = "poaceae",
                            "Hasel (Corylus)" = "corylus",
                            "Nessel- und Glaskraut (Urticaceae)" = "urticaceae",
                            "Ölbaum (Olea)" = "olea",
                            "Pilzsporen (Alternaria)" = "alternaria",
                            "Platane (Platanus)" = "platanus",
                            "Ragweed (Ambrosia)" = "ambrosia",
                            "Roggen (Secale)" = "secale",
                            "Zypressengewächse (Cupressaceae)" = "cupressaceae"), 
                    selected = "poaceae"), class="col-xs-9", style="margin-top:-28px;"))
tags$div(tags$strong("Zeitraum", class="col-xs-3"), tags$div(
        selectInput("timespan", label = span("Zeitraum", style="display:none;"), 
                    choices = list(
                            "2 Wochen" = 1,
                            "1 Monat" = 2,
                            "6 Monate" = 3,
                            "dieses Jahr" = 4,
                            "letztes Jahr" = 5),
                    selected = 1), class="col-xs-9", style="margin-top:-28px;"))
tags$div(uiOutput("pollGraph"), style="height:500px;")
```