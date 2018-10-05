# Interfaz para la generación de clusters
# David Montalván

library(shiny)

# Define la UI
shinyUI(fluidPage(
  
  # título
  titlePanel("Genera clusters"),
  
  # Barra lateral
    sidebarPanel(
      downloadButton('downloadData', 'Descarga datos')
    ),
  
  # Show a plot of the generated distribution
  mainPanel(
     plotOutput("plot", click = "plot_click", height = 600, width = 800)
    )
  )
)
