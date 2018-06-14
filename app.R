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
# http://127.0.0.1:1253/?PIA_URL=http://192.168.178.21:3000&APP_KEY=564b1586d79793160b18692bc95b918cc6096929285a493cb3b2726b6eaf6f38&APP_SECRET=94a405c13b5d78fbf0c63f71017c13ce83d750e363d7c19fcd083c2d7d6dde89&desktop=1