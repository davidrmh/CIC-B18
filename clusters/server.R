# Servidor para la generación de clusters
library(shiny)
shinyServer(function(input, output) {
  
  #Variable 'ubi' guarda la ubicación de los puntos
  ubi <- reactiveValues(
    x_cord = c(),
    y_cord = c(),
    tabla = NULL
  )
  
  #Observar el evento de un click en el gráfico
  observeEvent(input$plot_click, {
    ubi$x_cord <- c(ubi$x_cord, input$plot_click$x )
    ubi$y_cord <- c(ubi$y_cord, input$plot_click$y )
  })
  
  #Para graficar los puntos
  output$plot <- renderPlot({
      plot(0,0, cex = 0, main = "Dibuja los puntos")
      points(ubi$x_cord, ubi$y_cord, pch = 1, cex = 1.5)
    
  })
  
  #Para descargar los datos
  output$downloadData <- downloadHandler(
    filename = "cluster.csv",
    content = function(filename){
      
      #crea la tabla
      ubi$tabla <- data.frame(x = ubi$x_cord, y = ubi$y_cord)
      
      #guarda el archivo
      write.csv(ubi$tabla, file = filename, row.names = FALSE)
    }
  )
  
})
