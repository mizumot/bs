library(shiny)
library(psych)
library(beeswarm)



shinyServer(function(input, output) {
    
    options(warn=-1)
    
    bs <- reactive({
        x <- input$textarea.in
        x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
        result <- describe(x)[2:13]
        row.names(result) <- ""
        return(result)
    })



    makedistPlot <- function(){
        x <- input$textarea.in
        x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
        
        x <- x[!is.na(x)]
        
        simple.bincount <- function(x, breaks) {
            nx <- length(x)
            nbreaks <- length(breaks)
            counts <- integer(nbreaks - 1)
            for (i in 1:nx) {
                lo <- 1
                hi <- nbreaks
                if (breaks[lo] <= x[i] && x[i] <= breaks[hi]) {
                    while (hi - lo >= 2) {
                        new <- (hi + lo) %/% 2
                        if(x[i] > breaks[new])
                        lo <- new
                        else
                        hi <- new
                    }
                    counts[lo] <- counts[lo] + 1
                }
            }
            return(counts)
        }
        
        nclass <- nclass.FD(x)
        breaks <- pretty(x, nclass)
        counts <- simple.bincount(x, breaks)
        counts.max <- max(counts)
        
        h <- hist(x, las=1, breaks="FD", xlab= "Red vertical line shows the mean.",
        ylim=c(0, counts.max*1.2), main="", col = "cyan")
        rug(x)
        abline(v = mean(x, na.rm=T), col = "red", lwd = 2)
        xfit <- seq(min(x, na.rm=T), max(x, na.rm=T))
        yfit <- dnorm(xfit, mean = mean(x, na.rm=T), sd = sd(x, na.rm=T))
        yfit <- yfit * diff(h$mids[1:2]) * length(x)
        lines(xfit, yfit, col = "blue", lwd = 2)
    }


    output$distPlot <- renderPlot({
        print(makedistPlot())
    })
    
    
    
    makeboxPlot <- function(){
        x <- input$textarea.in
        x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
        
        boxplot(x, horizontal=TRUE, xlab= "Mean and +/-1 SD are displayed in red.")
        
        points(mean(x, na.rm=T), 0.9, pch = 18, col = "red", cex = 2)
        arrows(mean(x, na.rm=T), 0.9, mean(x, na.rm=T) + sd(x, na.rm=T), length = 0.1, angle = 45, col = "red")
        arrows(mean(x, na.rm=T), 0.9, mean(x, na.rm=T) - sd(x, na.rm=T), length = 0.1, angle = 45, col = "red")

        if (input$beeswarm == 0) {
            
            NULL
            
        } else {
            
            beeswarm(x, horizontal=TRUE, col = 4, pch = 16, add = TRUE)
        
        }
    }
    
    
    output$boxPlot <- renderPlot({
        print(makeboxPlot())
    })
    
    
    
    testnorm <- reactive({
        x <- input$textarea.in
        x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
        list(ks.test(scale(x), "pnorm"), shapiro.test(x))
    })
    
    
    
    makeqqPlot <- function(){
        x <- input$textarea.in
        x <- as.numeric(unlist(strsplit(x, "[\n, \t]")))
        qqnorm(x, las=1)
        qqline(x, col=2)
    }
    
    output$qqPlot <- renderPlot({
        print(makeqqPlot())
     })
    
    
    
    info <- reactive({
        info1 <- paste("This analysis was conducted with ", strsplit(R.version$version.string, " \\(")[[1]][1], ".", sep = "")
        info2 <- paste("It was executed on ", date(), ".", sep = "")
        cat(sprintf(info1), "\n")
        cat(sprintf(info2), "\n")
    })
    
    output$info.out <- renderPrint({
        info()
    })

    
    
    output$textarea.out <- renderPrint({
        bs()
    })
    
    output$testnorm.out <- renderPrint({
        testnorm()
    })
    
})