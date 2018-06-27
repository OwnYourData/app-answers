output$pollGraph <- renderUI({
        poll_info <- FALSE
        mood_info <- FALSE
        headers <- oydapp::defaultHeaders(app$token)
        mood_url <- oydapp::itemsUrl(app$url, "oyd.diary.mood")
        mood <- oydapp::readItems(app, mood_url)
        
        time_select <- input$timespan
        history <- 0
        year <- 0
        switch(time_select,
               "1" = { history <- 14 },
               "2" = { history <- 30 },
               "3" = { history <- 180 },
               "4" = { year <- format(Sys.Date(), "%Y") },
               "5" = { year <- as.character(as.numeric(format(Sys.Date(), "%Y"))-1) })
        
        if(year == 0){
                mood <- mood[as.Date(as.POSIXct(mood$timestamp, origin = "1970-01-01")) >= 
                                     Sys.Date() - history, ]
        } else {
                mood <- mood[format(as.Date(as.POSIXct(mood$timestamp, 
                                                       origin = "1970-01-01")), "%Y") == year, ]
        }
        if(nrow(mood) == 0){
                mood_info <- TRUE
        }
        
        repos <- tryCatch(RCurl::getURL(paste0(app$url, '/api/repos/index'),
                                        .opts=list(httpheader=headers)),
                          error=function(e){ return(NA) })
        repos_all <- jsonlite::fromJSON(repos)
        poll <- repos_all[grepl("^oyd.allergy.pollination", repos_all$name), ]
        if(nrow(poll) > 0){
                poll_name <- poll[1, 'name']
                poll_url <- oydapp::itemsUrl(app$url, poll_name)
                poll <- oydapp::readItems(app, poll_url)
                
                # !!! filter by timespan and poll selection
                poll_select <- input$pollination
                if(year == 0){
                        poll <- poll[
                                as.Date(poll$date) >= Sys.Date() - history &
                                        grepl(poll_select, 
                                              poll$pollType, 
                                              ignore.case = TRUE), ]
                } else {
                        poll <- poll[format(as.Date(poll$date), "%Y") == year &
                                             grepl(poll_select,
                                                   poll$pollType,
                                                   ignore.case = TRUE), ]
                }
                
                if(nrow(poll) > 0){
                        # prepare data for graph
                        mood$date <- as.Date(as.POSIXct(mood$timestamp, origin = "1970-01-01"))
                        poll$date = as.Date(poll$date)
                        dates <- unique(c(mood$date, poll$date))
                        dates <- dates[sort.list(dates)]
                        df <- data.frame(date = dates)
                        df <- merge(x=df, y=mood[, c('date', 'mood')], by='date', all.x=TRUE)
                        df <- merge(x=df, y=poll[, c('date', 'value')], by='date', all.x=TRUE)
                        
                        x <- as.numeric(as.POSIXct(df[df$date <= Sys.Date(), 'date']))
                        y <- as.numeric(df[df$date <= Sys.Date(), 'value'])
                        x_fc <- as.numeric(as.POSIXct(df[df$date >= Sys.Date(), 'date']))
                        y_fc <- as.numeric(df[df$date >= Sys.Date(), 'value'])
                        x_mood <- as.numeric(as.POSIXct(df[, 'date']))
                        y_mood <- as.numeric(df[, 'mood'])
                        
                        p <- ggplot() 
                        p <- p + geom_line(
                                aes_(x = as.Date(as.POSIXct(x[!is.na(y)], origin = "1970-01-01")),
                                     y = y[!is.na(y)],
                                     colour = poll[1, 'pollType']),
                                size = 1.5,
                                linetype = 1)
                        if(length(x_fc) > 0){
                                p <- p + geom_line(
                                        aes_(x = as.Date(as.POSIXct(x_fc, origin = "1970-01-01")),
                                             y = y_fc,
                                             colour = poll[1, 'pollType']),
                                        size = 1.5,
                                        linetype = 2)
                        }
                        p <- p + geom_point(
                                aes_(x = as.Date(as.POSIXct(x, origin = "1970-01-01")),
                                     y = y),
                                color="#555555")
                        if(length(y_mood) > 0){
                                if(length(y_mood[!is.na(y_mood)]) > 1){
                                        p <- p + geom_line(
                                                aes_(x = as.Date(as.POSIXct(x_mood[!is.na(y_mood)], origin = "1970-01-01")),
                                                     y = y_mood[!is.na(y_mood)]/6*5-1,
                                                     colour = "Mood"),
                                                size = 1.5,
                                                linetype = 1)
                                }
                                p <- p + geom_point(
                                        aes_(x = as.Date(as.POSIXct(x_mood, origin = "1970-01-01")),
                                             y = y_mood/6*5-1,
                                             colour = "Mood"),
                                        color="#555555")
                        }
                        p <- p + expand_limits(y=c(0, 4))
                        p <- p + scale_y_continuous(
                                sec.axis = sec_axis(~(.+1)*6/5,
                                                    name = "< schlecht - Stimmung - gut >",
                                                    breaks = 1:6))
                        p <- p + labs(y = "< schwach - Pollenbelastung - stark >",
                                      x = "",
                                      colour = "")
                        switch(time_select,
                               "1" = { p <- p + scale_x_date(date_breaks = "1 day",
                                                             date_minor_breaks = "1 day",
                                                             date_labels = "%a %d.%m") },
                               "2" = { p <- p + scale_x_date(date_breaks = "1 week",
                                                             date_minor_breaks = "1 day",
                                                             date_labels = "%a %d.%m") },
                               "3" = { p <- p + scale_x_date(date_breaks = "1 month",
                                                             date_minor_breaks = "1 week",
                                                             date_labels = "%a %d.%m") },
                               "4" = { p <- p + scale_x_date(date_breaks = "1 month",
                                                             date_minor_breaks = "1 week",
                                                             date_labels = "%a %d.%m") },
                               "5" = { p <- p + scale_x_date(date_breaks = "1 month",
                                                             date_minor_breaks = "1 week",
                                                             date_labels = "%a %d.%m") })
                        p <- p + scale_colour_manual("", values = c("red", "green"))
                        p <- p + theme_bw()
                        p <- p + theme(
                                axis.text.x = element_text(angle = 25,
                                                           vjust = 1.0,
                                                           hjust = 1.0),
                                legend.position="bottom")
                        
                        p
                } else {
                        poll_info <- TRUE
                }
        }                
        
        if(poll_info && mood_info){
                tagList(
                        tags$p("Hinweis: für den gewählten Zeitraum stehen keine Informationen zu Pollenbelastung und Stimmung zur Verfügung", 
                               style="text-align: center;"))
        } else {
                if(poll_info){
                        tags$p("Hinweis: für den gewählten Zeitraum stehen keine Informationen über die Pollenbelastung zur Verfügung", 
                               style="text-align: center;")
                } else {
                        if(mood_info){
                                tagList(tags$p("Hinweis: für den gewählten Zeitraum stehen keine Informationen über die Stimmung zur Verfügung", 
                                               style="text-align: center;"),
                                        renderPlot({ p }))
                        } else {
                                tagList(renderPlot({ p }))
                        }
                }
        }
})
