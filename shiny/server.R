shinyServer(function(input, output) {
  output$samplesizes <- renderTable({
    if (input$radio == 0) {
      table(dhr[,geo_factors[as.numeric(input$radio_geo)]], dnn="Freq")
    } else {
      table(dhr[,geo_factors[as.numeric(input$radio_geo)]], dhr[,radio_factors[as.numeric(input$radio)]],
            dnn=c("Geo", radio_factors[as.numeric(input$radio)]))
    }
  })
  output$map <- renderPlot({
    if (input$radio %in% c(0,3,4)) {
      mydata <- get_geo_df(as.character(input$variable),
                           as.character(geo_factors[as.numeric(input$radio_geo)]))
      panelvars <- input$variable
    } else {
      mydata <- get_geo_df(as.character(input$variable),
                           as.character(geo_factors[as.numeric(input$radio_geo)]),
                           radio_factors[as.numeric(input$radio)])
      panelvars <- names(mydata)[! names(mydata) %in% names(gnh)]
    }
    # Prettier options for trellis to remove ugly borders
    trellis.par.set(axis.line=list(col=NA))
    trellis.par.set(strip.background=list(col=NA))
    trellis.par.set(strip.border=list(col=NA))
    trellis.par.set(axis.line=list(col=NA))
    spplot(mydata, zcol=panelvars,
           col.regions=rainbow(255, start=0.5),
           main=input$variable,
           sp.layout=list("sp.text", coordinates(gnh), gnh$TOWN, cex=0.8, col="black"),
           at=seq(min(dhr[,input$variable], na.rm=TRUE), max(dhr[,input$variable], na.rm=TRUE), by=(max(dhr[,input$variable], na.rm=TRUE) - min(dhr[,input$variable], na.rm=TRUE)) / 255),
           col="gray")
  })
  output$hist <- renderPlot({
    if (input$radio == 0) {
      ggplot(dhr, aes_string(x=input$variable)) + geom_bar(fill="#F8766D", col="gray") + theme_classic()
    } else {
      ggplot(dhr, aes_string(x=input$variable, fill=paste0("as.factor(", radio_factors[as.numeric(input$radio)], ")"))) + geom_bar(position="dodge") + theme_classic()
    }
  })
  output$boxplot <- renderPlot({
    if (input$radio == 0) {
      ggplot(dhr, aes_string(y=input$variable)) +
        geom_boxplot(aes(x=factor(1), fill=factor(1))) +
        xlab("Group") +
        coord_flip() +
        guides(fill=FALSE) +
        theme_classic()
    } else {
      ggplot(dhr, aes_string(y=input$variable,
                             x=paste0("as.factor(", radio_factors[as.numeric(input$radio)], ")"),
                             fill=paste0("as.factor(", radio_factors[as.numeric(input$radio)], ")"))) +
        geom_boxplot() +
        xlab("Group") +
        coord_flip() +
        theme_classic()
    }
  })
  output$crosstab <- renderTable({
    if (input$radio == 0) {
      round(prop.table(table(dhr[,input$variable])), 3)
    } else {
      mytable <- table(dhr[,input$variable], dhr[,radio_factors[as.numeric(input$radio)]])
      round(prop.table(mytable, if(input$radio_table==0) {NULL} else {as.numeric(input$radio_table)} ), 3)
    }
  })
})
