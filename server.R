library(shiny)
library(psych)

shinyServer(function(input, output) {

  options(warn=-1)
  
  bs <- reactive({
    x <- input$textarea.in
    x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
    result <- describe(x)[2:13]
    row.names(result) <- ""
    return(result)
    })

   output$distPlot <- renderPlot({
    x <- input$textarea.in
    x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
    hist(x, breaks="FD",main="", xlab="", col = "cyan")
    rug(x)
    abline(v = mean(x, na.rm=T), col = "red", lwd = 2)
    })

   output$boxPlot <- renderPlot({
    x <- input$textarea.in
    x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
    boxplot(x, horizontal=TRUE, xlab= "Mean and +/-1 SD are displayed in red.")
    stripchart(x, pch = 16, add = TRUE)
    points(mean(x, na.rm=T), 0.9, pch = 18, col = "red", cex = 2)
    arrows(mean(x, na.rm=T), 0.9, mean(x, na.rm=T) + sd(x, na.rm=T), length = 0.1, angle = 45, col = "red")
    arrows(mean(x, na.rm=T), 0.9, mean(x, na.rm=T) - sd(x, na.rm=T), length = 0.1, angle = 45, col = "red")
    })

   testnorm <- reactive({
    x <- input$textarea.in
    x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
    list(ks.test(scale(x), "pnorm"), shapiro.test(x)
    )
    })
   
   output$qqPlot <- renderPlot({
    x <- input$textarea.in
    x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
    qqnorm(x)
    qqline(x, col=2)
    })


output$textarea.out <- renderPrint({
    bs()
    })
  
output$testnorm.out <- renderPrint({
    testnorm()
    })

})
