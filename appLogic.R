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
                query <- parseQueryString(session$clientData$url_search)
                if(!is.null(query[['page']])){
                        app <- setupApp(session$userData$piaUrl,
                                        session$userData$appKey,
                                        session$userData$appSecret,
                                        session$userData$keyItems)
                        answer_url <- paste0(app['url'], '/api/answers/index')
                        headers <- defaultHeaders(app$token)
                        header <- RCurl::basicHeaderGatherer()
                        answers <- tryCatch(
                                RCurl::getURI(answer_url,
                                              .opts=list(httpheader = headers),
                                              headerfunction = header$update),
                                error = function(e) { return(NA) })
                        answer_list <- as.data.frame(jsonlite::fromJSON(answers))
                        short <- answer_list[answer_list$identifier == query[['page']], 'short']

                        protocol <- ""
                        if (nzchar(session$clientData$url_protocol) > 0) {
                                protocol <- paste0(session$clientData$url_protocol, '//')
                        }
                        port <- ""
                        if (nzchar(session$clientData$url_port) > 0) {
                                port <- paste0(':', session$clientData$url_port)
                        }
                        desktop <- ""
                        if (!is.null(query[['desktop']])){
                                desktop <- "?desktop=1"
                        }
                        
                        back_url <- paste0(
                                protocol,
                                session$clientData$url_hostname,
                                port,
                                session$clientData$url_pathname,
                                desktop)
                        
                        output$hdrPiaLinkImg <- renderUI({
                                tags$div(
                                        tags$a(href=back_url,
                                               style='color:#777; text-decoration: none;',
                                               icon('arrow-left')),
                                        style='display: inline;'
                                )
                        })
                        
                        output$hdrTitle <- renderUI({
                                tags$div(short,
                                         style="color:#777;
                                         text-align: center;")
                        })
                }
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
        answer_url <- paste0(app['url'], '/api/answers/index')
        headers <- defaultHeaders(app$token)
        header <- RCurl::basicHeaderGatherer()
        answers <- tryCatch(
                RCurl::getURI(answer_url,
                              .opts=list(httpheader = headers),
                              headerfunction = header$update),
                error = function(e) { return(NA) })
        if(is.na(answers)){
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
                desktop <- ""
                if ((length(query) > 0) && !is.null(query[['desktop']])){
                        desktop <- "&desktop=1"
                }
                answer_list <- as.data.frame(jsonlite::fromJSON(answers))
                # iterate over answer_list to add attributes for record cound and date
                for(i in rownames(answer_list)){
                        repos_df <- jsonlite::fromJSON(answer_list[i, "repos"])
                        count <- 0
                        since <- NULL
                        for(j in rownames(repos_df)){
                                # tmp <- oydapp::readRawItems(app, oydapp::itemsUrl(app$url, repos_df[j, "repo"]))
                                # count <- count + nrow(tmp)
                                repo_url <- paste0(app$url, 
                                                   "/api/repos/", 
                                                   repos_df[j, "repo"], 
                                                   "/identifier")
                                tmp <- tryCatch(
                                        RCurl::getURI(repo_url,
                                                      .opts=list(httpheader = headers),
                                                      headerfunction = header$update),
                                        error = function(e) { return(NA) })
                                if(!is.na(tmp) && (tmp != "null") && jsonlite::validate(tmp)){
                                        pr <- jsonlite::fromJSON(tmp)
                                        ca <- as.character(pr$created_at)
                                        tmp_date <- as.POSIXct(ca)
                                        if (is.null(since) || ((length(tmp_date) > 0) && (since > tmp_date))){
                                                since = tmp_date
                                        }
                                        tmp_count <- as.integer(pr$items)
                                        if(length(tmp_count) > 0){
                                                count <- count + tmp_count
                                        }
                                }
                        }
                        if(count > 0) {
                                answer_list[i, "count"] = count
                        } else {
                                answer_list[i, "count"] = 0
                        }
                        if(!is.null(since)){
                                answer_list[i, "since"] = since
                        } else {
                                answer_list[i, "since"] = ""
                        }
                        answer_list[i, "cat_text"] <- tr(answer_list[i, "category"])
                        answer_list[i, "cat_color"] <- switch(answer_list[i, "category"],
                                "time"="blue",
                                "finance"="green",
                                "health"="red",
                                "online"="aqua",
                                "social"="fuchsia",
                                "housing"="darkkhaki",
                                "mobility"="indigo")
                }
                if(is.null(query[['page']])){
                        output_html <- ""
                        if(nrow(answer_list) > 0){
                                output_html <- paste0(
                                        "<div class='row'><div class='col-md-6'>", 
                                                paste0(
                                                        paste0(
                                                                "<a href='", current_url, "?page=", answer_list[,'identifier'], desktop, "' style='text-decoration: none;'>",
                                                                        "<div style='border-top: 1px lightgray;
                                                                                                        border-right: 2px lightgray;
                                                                                                        border-bottom: 2px lightgray;
                                                                                                        border-left: 5px ", answer_list[,'cat_color'], ";
                                                                                                        border-style: solid;
                                                                                                        padding: 5px;
                                                                                                        margin: 15px;'>",
                                                                                "<p style='float: left;
                                                                                                width: 70%;
                                                                                                text-decoration: none;
                                                                                                color: black;
                                                                                                font-size: larger;'>", 
                                                                                        answer_list[,'name'], 
                                                                                "</p>",
                                                                                "<div style='float: right;
                                                                                                color: white;
                                                                                                background-color: ", answer_list[,'cat_color'], ";
                                                                                                padding: 2px 10px;
                                                                                                margin: -5px;'>", 
                                                                                        answer_list[,'cat_text'], 
                                                                                "</div>",
                                                                                "<div style='clear: both;'></div>", 
                                                                                "<div style='color: gray;'>", 
                                                                                        format(as.integer(answer_list[, 'count']), big.mark = ".", decimal.mark = ","), 
                                                                                        " ", tr('records_since'), " ",
                                                                                        as.character(as.POSIXct(answer_list[, 'since'], origin = "1970-01-01")),
                                                                                "</div>",
                                                                        "</div>",
                                                                "</a>"), 
                                                        collapse="</div><div class='col-md-6'>"), 
                                        "</div></div>")
                        } else {
                                output_html <- paste0("<p>", tr('missingData'), "</p>")
                        }
                        HTML(output_html)
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
                        answer_logic <- answer_list[answer_list$identifier == query[['page']], 'answer_logic']
                        answer_logic <- rawToChar(jsonlite::base64_dec(answer_logic))
                        answer_logic <- gsub("\r\n", "\n", answer_logic)
                        repos_df <- jsonlite::fromJSON(answer_list[answer_list$identifier == query[['page']], 'repos'])
                        # for(j in rownames(repos_df)){
                        #         answer_logic <- gsub(paste0("[oyd_", 
                        #                                     repos_df[j, "name"], 
                        #                                     "_oyd]"), 
                        #                              repos_df[j, "repo"], 
                        #                              answer_logic,
                        #                              fixed = TRUE)
                        # }
                        answer_view <- answer_list[answer_list$identifier == query[['page']], 'answer_view']
                        answer_view <- rawToChar(jsonlite::base64_dec(answer_view))
                        eval(parse(text = answer_logic))
                        
                        save(answer_view, answer_logic, file='tmpInv0.RData')
                        
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
                                HTML
                }
        }
})
