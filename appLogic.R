# application specific logic
# last update: 2017-06-11

# Code required for every app ========================
# initialization
session$userData$piaUrl <- ''
session$userData$appKey <- ''
session$userData$appSecret <- ''
session$userData$keyItems <- data.frame()
session$userData$initFlag <- TRUE
session$userData$openDialog <- ''

appServer <- function(input, output, session, tr, notif){
        appStart <- function(){
        }
        
        return(appStart)
}

# App specific code =======================================
output$pageStub <- renderUI({
        rv$u
        app <- setupApp(session$userData$piaUrl,
                        session$userData$appKey,
                        session$userData$appSecret,
                        session$userData$keyItems)
        quest_url <- paste0(app['url'], '/api/reports/index')
        headers <- defaultHeaders(app$token)
        header <- RCurl::basicHeaderGatherer()
        reports <- tryCatch(
                RCurl::getURI(quest_url,
                              .opts=list(httpheader = headers),
                              headerfunction = header$update),
                error = function(e) { return(NA) })
        if(is.na(reports)){
                tagList(
                        p(""),
                        br(),
                        p(""))
        } else {
                protocol <- ""
                if (nzchar(session$clientData$url_protocol) > 0) {
                        protocol <- paste0(session$clientData$url_protocol, '//')
                }
                port <- ""
                if (nzchar(session$clientData$url_port) > 0) {
                        port <- paste0(':', session$clientData$url_port)
                }
                current_url <- paste0(
                        protocol,
                        session$clientData$url_hostname,
                        port,
                        session$clientData$url_pathname)
                query <- parseQueryString(session$clientData$url_search)
                report_list <- as.data.frame(jsonlite::fromJSON(reports))
                if(is.null(query[['page']])){
                        HTML(paste0("<p>", 
                                    paste(paste0('<strong>', 
                                                 report_list[,'name'],
                                                 '</strong> <a href="',
                                                 current_url,
                                                 '?page=',
                                                 report_list[,'identifier'],
                                                 '">show</a>'), 
                                          collapse = "</p><p>"), 
                                    "</p>"))
                } else {
                        # current_data <- report_list[report_list$identifier == query[['page']], 'current']
                        # key <- as.character(session$userData$keyItems[['key']])
                        # data_snippet <- oydapp::msgDecrypt(current_data, key)
                        # HTML(paste0(data_snippet,
                        #         ' <a href="', current_url, '">back</a>'))
                        
                        encoding <- getOption("shiny.site.encoding", default = "UTF-8")
                        knitr::opts_chunk$set(
                                echo = FALSE,
                                comment = NA,
                                cache = FALSE,
                                message = FALSE,
                                warning = FALSE
                        )
                        current_data <- report_list[report_list$identifier == query[['page']], 'current']
                        key <- as.character(session$userData$keyItems[['key']])
                        if (nchar(current_data) > 0 && length(key) > 0 && nchar(key) > 0){
                                data_snippet <- oydapp::msgDecrypt(current_data, key)
                                answer_logic <- report_list[report_list$identifier == query[['page']], 'answer_logic']
                                answer_logic <- rawToChar(jsonlite::base64_dec(answer_logic))
                                answer_logic <- gsub('\\[DATA_SNIPPET\\]',
                                                     data_snippet,
                                                     answer_logic)
                                answer_logic <- gsub("\r\n", "\n", answer_logic)
                                answer_view <- report_list[report_list$identifier == query[['page']], 'answer_view']
                                answer_view <- rawToChar(jsonlite::base64_dec(answer_view))
                                answer_view <- gsub('\\[DATA_SNIPPET\\]',
                                                    data_snippet,
                                                    answer_view)
                                eval(parse(text = answer_logic))

                                answer_view %>%
                                        knitr::knit2html(
                                                text = .,
                                                fragment.only = TRUE,
                                                envir = parent.frame(),
                                                options = "",
                                                stylesheet = "",
                                                encoding = encoding
                                        ) %>%
                                        gsub("&lt;!--/html_preserve--&gt;","",.) %>%
                                        gsub("&lt;!--html_preserve--&gt;","",.) %>%
                                        paste(., ' <a href="', current_url, '">back</a>') %>%
                                        HTML
                        }
                }
        }
})
