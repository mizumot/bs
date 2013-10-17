library(shiny)
library(psych)

shinyServer(function(input, output) {

  options(warn=-1)
  
  bs <- reactive({
    x <- input$textarea.in
    x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
    return(describe(x))
    })

   output$distPlot <- renderPlot({
    x <- input$textarea.in
    x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
    hist(x, breaks="FD",main="", xlab="", col = "cyan")
    abline(v = mean(x), col = "red", lwd = 2)
    })

   output$boxPlot <- renderPlot({
    x <- input$textarea.in
    x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
    boxplot(x, horizontal=TRUE)
    stripchart(x, pch = 16, horizontal=TRUE, add = TRUE)
    abline(v = mean(x), col = "red", lwd = 2)
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
