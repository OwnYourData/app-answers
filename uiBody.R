uiBody <- function(ns){
        fluidRow(
                column(1),
                column(10,
                       uiOutput("pageStub"),
                       htmltools::attachDependencies(
                               htmltools::tagList(),
                               c(
                                       htmlwidgets:::getDependency("renderLeaflet","leaflet"),
                                       htmlwidgets:::getDependency("addProviderTiles","leaflet"),
                                       htmlwidgets:::getDependency("addMarkers","leaflet"),
                                       htmlwidgets:::getDependency("leaflet","leaflet")
                               )
                       )
                )
        )
}