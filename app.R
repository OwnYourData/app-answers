# top-level file for shiny app
# last update: 2018-03-07

# app wide constants and functions
source('constants.R')

server <- function(input, output, session) {
        source('appLogic.R', local=TRUE)
        tr <- callModule(srvLocalization, 'oyd')
        notif <- callModule(srvNotification, 'oyd', tr)
        appStart <- callModule(appServer, 'oyd', tr, notif)
        callModule(srvModule, 'oyd', tr, notif, appStart)
}

shinyApp(ui = uiSimple('oyd'), server = server)

# first start
# library(shiny); install.packages('~/oyd/base/oydapp/', repos=NULL, type='source'); library(oydapp); runApp('~/oyd/views/app-answers', host='0.0.0.0', port=1253)
# afterwards
# detach('package:oydapp', unload = TRUE); install.packages('~/oyd/base/oydapp/', repos=NULL, type='source'); library(oydapp); runApp('~/oyd/views/app-answers', host='0.0.0.0', port=1253)
