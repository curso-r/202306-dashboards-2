library(shiny)

ui <- fluidPage(
  ui_grafico_dispersao(),
  hr(),
  ui_histograma()
)

server <- function(input, output, session) {

  output$grafico_dispersao <- renderPlot({
    plot(x = mtcars[[input$variavel_x]], y = mtcars[[input$variavel_y]])
  })

  output$histograma <- renderPlot({
    hist(mtcars[[input$variavel]])
  })


}

shinyApp(ui, server, options = list(launch.browser = FALSE, port = 4242))
